import 'package:collection/collection.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter/src/core/input.dart';
import 'package:image_size_getter/src/decoder/gif_decoder.dart';

import 'package:image_size_getter/src/decoder/jpeg_decoder.dart';
import 'package:image_size_getter/src/decoder/png_decoder.dart';
import 'package:image_size_getter/src/decoder/webp_decoder.dart';
export 'core/input.dart';

class ImageSizeGetter {
  static bool isJpg(ImageInput input) {
    if (input == null || !input.exists()) {
      return false;
    }

    const start = [0xFF, 0xD8];
    const end = [0xFF, 0xD9];

    final length = input.length;
    final startList = input.getRange(0, 2);
    final endList = input.getRange(length - 2, length);

    const eq = ListEquality();

    return eq.equals(start, startList) && eq.equals(end, endList);
  }

  static bool isPng(ImageInput input) {
    final length = input.length;

    final start = input.getRange(0, 8);
    final end = input.getRange(length - 12, length);
    const eq = IterableEquality();
    if (eq.equals(start, _PngHeaders.sig) && eq.equals(end, _PngHeaders.iend)) {
      return true;
    }

    return false;
  }

  static bool isWebp(ImageInput input) {
    final sizeStart = input.getRange(0, 4);
    final sizeEnd = input.getRange(8, 12);

    const eq = ListEquality();

    if (eq.equals(sizeStart, _WebpHeaders.fileSizeStart) &&
        eq.equals(sizeEnd, _WebpHeaders.fileSizeEnd)) {
      return true;
    }
    return false;
  }

  static bool isGif(ImageInput input) {
    const eq = ListEquality();
    final length = input.length;

    final sizeStart = input.getRange(0, 6);
    final sizeEnd = input.getRange(length - 1, length);

    return eq.equals(sizeStart, _GifHeaders.start) &&
        eq.equals(sizeEnd, _GifHeaders.end);
  }

  static Size getSize(ImageInput input) {
    if (input == null) {
      throw 'The input must not be null.';
    }
    if (!input.supportSync) {
      throw "The input cannot support sync call. Please use AsyncImageSizeGetter.getSize().";
    }
    if (isJpg(input)) {
      return JpegDecoder(input).size;
    }
    if (isPng(input)) {
      return PngDecoder(input).size;
    }
    if (isWebp(input)) {
      return WebpDecoder(input).size;
    }
    if (isGif(input)) {
      return GifDecoder(input).size;
    }
    return Size.zero;
  }
}

class AsyncImageSizeGetter {
  static Future<Size> getSize(ImageInput input) async {
    if (input == null) {
      throw 'The input must not be null.';
    }
    if (input.supportSync) {
      return ImageSizeGetter.getSize(input);
    }
    if (await isJpg(input)) {
      return JpegDecoder(input).size;
    }
    if (await isPng(input)) {
      return PngDecoder(input).size;
    }
    if (await isWebp(input)) {
      return WebpDecoder(input).size;
    }
    if (await isGif(input)) {
      return GifDecoder(input).size;
    }
    return Size.zero;
  }

  static Future<bool> isJpg(ImageInput input) async {
    if (input == null || !input.exists()) {
      return false;
    }

    const start = [0xFF, 0xD8];
    const end = [0xFF, 0xD9];

    final length = await input.lengthAsync;
    final startList = await input.getRangeAsync(0, 2);
    final endList = await input.getRangeAsync(length - 2, length);

    const eq = ListEquality();

    return eq.equals(start, startList) && eq.equals(end, endList);
  }

  static Future<bool> isPng(ImageInput input) async {
    final length = input.length;

    final start = await input.getRangeAsync(0, 8);
    final end = await input.getRangeAsync(length - 12, length);
    const eq = IterableEquality();
    if (eq.equals(start, _PngHeaders.sig) && eq.equals(end, _PngHeaders.iend)) {
      return true;
    }

    return false;
  }

  static Future<bool> isWebp(ImageInput input) async {
    final sizeStart = await input.getRangeAsync(0, 4);
    final sizeEnd = await input.getRangeAsync(8, 12);

    const eq = ListEquality();

    if (eq.equals(sizeStart, _WebpHeaders.fileSizeStart) &&
        eq.equals(sizeEnd, _WebpHeaders.fileSizeEnd)) {
      return true;
    }
    return false;
  }

  static Future<bool> isGif(ImageInput input) async {
    const eq = ListEquality();
    final length = input.length;

    final sizeStart = await input.getRangeAsync(0, 6);
    final sizeEnd = await input.getRangeAsync(length - 1, length);

    return eq.equals(sizeStart, _GifHeaders.start) &&
        eq.equals(sizeEnd, _GifHeaders.end);
  }
}

class _PngHeaders {
  static const sig = [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
  ];

  static const iend = [
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82
  ];
}

class _WebpHeaders {
  static const fileSizeStart = [
    0x52,
    0x49,
    0x46,
    0x46,
  ];

  static const fileSizeEnd = [
    0x57,
    0x45,
    0x42,
    0x50,
  ];
}

class _GifHeaders {
  static const start = [
    0x47,
    0x49,
    0x46,
    0x38,
    0x39,
    0x61,
  ];

  static const end = [0x3B];
}
