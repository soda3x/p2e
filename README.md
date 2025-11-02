# p2e

Convert PDFs to EPUBs without any loss in quality

## Usage

For a single file:

```sh
./p2e.sh my-pdf-file.pdf
```

For entire directories (and optionally subdirectories):

```sh
./p2e-batch.sh <path/to/my/pdfs> [r | -recursive]
```

## Dependencies

* perl
* zip
* poppler-utils
