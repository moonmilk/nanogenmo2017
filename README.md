# A Human Docum•nt
## for nanogenmo2017
A Human Docum•nt: an •xpurgated nov•l for NaNoGenMo 2017

In Tom Phillips' [A Humument](http://www.tomphillips.co.uk/humument) (1973), he took an obscure Victorian Novel, A Human Document, and painted and collaged over the pages to make a new book. In that spirit, I downloaded [scans of A Human Document](https://archive.org/details/humandocumentnov01malluoft) from archive.org, and wrote a program which blots out all the e's in the book. The expurgator gets angrier and more forceful as the book progresses.

This is a [project](https://github.com/NaNoGenMo/2017/issues/115) for [NaNoGenMo 2017](https://github.com/NaNoGenMo/2017/), the yearly challenge to write a program to generate a novel.

## read it
https://archive.org/details/a-human-docum-nt

## watch the trailer
Why did I make a trailer?

[![preview image and link to youtube video](https://img.youtube.com/vi/yKq9d2IgPvw/0.jpg)](https://www.youtube.com/watch?v=yKq9d2IgPvw)

## some progress notes
over at https://github.com/NaNoGenMo/2017/issues/115

## code

The code is a bit of a mess because I put it together in parts over several years. It probably won't run without some fiddling.

I downloaded all the scanned pages of the original book and submitted them to ABBYY's online OCR service, 6 pages per image. I've lost the code that I used to submit the images. The result was one XML document for each set of 6 pages. All the OCR XMLs are in `6ocrsFrom6ups`

The processing sketch `inhumument.pde` (with its helper classes `CharInfo.pde`, `WordInfo.pde`, `LineInfo.pde` and `PageInfo.pde`) reads in all the XML documents and the original image files, and generates output in the form of two-page spreads. It does two pages at a time so it can simulate the bleed-through of the expurgation markings from one face of each page to the other. 

I plan to do more ambitious projects with this pile of images and data in the future!
