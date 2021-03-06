#include "ok_jpg.h"
#include "ok_png.h"
#include "ok_wav.h"
#include "ok_fnt.h"
#include "ok_csv.h"
#include "ok_mo.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION

static void printHelp() {
    fprintf(stderr, "Reads a png, jpg, wav, fnt, csv, or mo file from stdin. "
            "Useful for fuzzing.\n\n");
    fprintf(stderr, "One of these arguments required: --png --jpg --wav --fnt --csv --mo\n");
    fprintf(stderr, "Options for png and jpg: --format-bgra --format-pre --format-flip\n");
}

int main(int argc, char *argv[]) {
    int test_png = 0;
    int test_jpg = 0;
    int test_wav = 0;
    int test_fnt = 0;
    int test_csv = 0;
    int test_mo = 0;
    ok_png_decode_flags png_flags = OK_PNG_COLOR_FORMAT_RGBA;
    ok_jpg_decode_flags jpg_flags = OK_JPG_COLOR_FORMAT_RGBA;

    for (int i = 1; i < argc; i++) {
        if (strcmp("--format-bgra", argv[i]) == 0) {
            png_flags |= OK_PNG_COLOR_FORMAT_BGRA;
            jpg_flags |= OK_PNG_COLOR_FORMAT_BGRA;
        } else if (strcmp("--format-pre", argv[i]) == 0) {
            png_flags |= OK_PNG_PREMULTIPLIED_ALPHA;
        } else if (strcmp("--format-flip", argv[i]) == 0) {
            png_flags |= OK_PNG_FLIP_Y;
            jpg_flags |= OK_JPG_FLIP_Y;
        } else if (strcmp("--png", argv[i]) == 0) {
            test_png = 1;
        } else if (strcmp("--jpg", argv[i]) == 0) {
            test_jpg = 1;
        } else if (strcmp("--wav", argv[i]) == 0 || strcmp("--caf", argv[i]) == 0) {
            test_wav = 1;
        } else if (strcmp("--fnt", argv[i]) == 0) {
            test_fnt = 1;
        } else if (strcmp("--csv", argv[i]) == 0) {
            test_csv = 1;
        } else if (strcmp("--mo", argv[i]) == 0) {
            test_mo = 1;
        } else {
            fprintf(stderr, "Unrecognized argument: %s\n\n", argv[i]);
            printHelp();
            abort(); // Prevent fuzzer from continuing
            return 1;
        }
    }

    if (test_png + test_jpg + test_wav + test_fnt + test_csv + test_mo != 1) {
        printHelp();
        abort(); // Prevent fuzzer from continuing
        return 1;
    }

    if (test_png) {
        ok_png *png = ok_png_read(stdin, png_flags);
        if (png->error_message) {
            fprintf(stderr, "%s\n", png->error_message);
        }
        ok_png_free(png);
    } else if (test_jpg) {
        ok_jpg *jpg = ok_jpg_read(stdin, jpg_flags);
        if (jpg->error_message) {
            fprintf(stderr, "%s\n", jpg->error_message);
        }
        ok_jpg_free(jpg);
    } else if (test_wav) {
        ok_wav *wav = ok_wav_read(stdin, OK_WAV_DEFAULT_DECODE_FLAGS);
        if (wav->error_message) {
            fprintf(stderr, "%s\n", wav->error_message);
        }
        ok_wav_free(wav);
    } else if (test_fnt) {
        ok_fnt *fnt = ok_fnt_read(stdin);
        if (fnt->error_message) {
            fprintf(stderr, "%s\n", fnt->error_message);
        }
        ok_fnt_free(fnt);
    } else if (test_csv) {
        ok_csv *csv = ok_csv_read(stdin);
        if (csv->error_message) {
            fprintf(stderr, "%s\n", csv->error_message);
        }
        ok_csv_free(csv);
    } else if (test_mo) {
        ok_mo *mo = ok_mo_read(stdin);
        if (mo->error_message) {
            fprintf(stderr, "%s\n", mo->error_message);
        }
        ok_mo_free(mo);
    }

    return 0;
}

#endif
