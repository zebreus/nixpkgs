# Asciidoctor.js

## Introduction

This contains instructions on how to use asciidoctor-js.

The various extensions will be listed here somewhere.

## Customizing extensions

You can load custom extensions by overriding the extensions parameter

```
# Load the asciidoctor-tweet extension.
my-asciidoctor-web-pdf = asciidoctor-web-pdf.override {
  extensions = [ asciidoctor-js.allExtensions.asciidoctor-tweet ];
};
```
