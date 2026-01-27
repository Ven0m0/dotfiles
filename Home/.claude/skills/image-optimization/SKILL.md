---
name: image-optimization
description: "Optimize images for web performance. Auto-triggers on: optimize images, compress images, webp convert, image size, responsive images, lazy loading, srcset."
triggers: [optimize images, compress, webp, image size, responsive, lazy loading, srcset, thumbnail]
related: [file-organizer, modern-tool-substitution]
---

# Image Optimization

Reduce image file size without sacrificing quality.

## Format Selection

| Format | Best For | Command |
|--------|----------|---------|
| JPEG | Photos | `convert img.jpg -quality 75 out.jpg` |
| PNG | Icons, transparency | `optipng -o3 img.png` |
| WebP | Modern browsers (90%) | `cwebp -q 75 img.jpg -o img.webp` |
| SVG | Logos, scalable | `svgo img.svg -o out.svg` |

## Compression Levels

**Conservative (95%):** JPEG 85-90, PNG lossless
**Moderate (90%):** JPEG 75-80, PNG quantized
**Aggressive (80%):** JPEG 60-70, thumbnails

## Responsive Images

```html
<!-- srcset -->
<img src="img.jpg"
  srcset="small.jpg 480w, medium.jpg 768w, large.jpg 1200w"
  sizes="(max-width: 480px) 100vw, 80vw"
  alt="Description" loading="lazy" />

<!-- picture with fallback -->
<picture>
  <source srcset="img.webp" type="image/webp">
  <img src="img.jpg" alt="Description">
</picture>
```

## Quick Wins

```bash
# Remove EXIF (saves 20-50KB)
convert img.jpg -strip img-clean.jpg

# Batch convert to WebP
cwebp -q 75 *.jpg

# Batch resize + compress
mogrify -quality 75 -resize 1920x1080 *.jpg
```

## Targets

- Hero: <200KB | Thumbnail: <30KB | Icon: <5KB
- Total images: <500KB | Gzipped: <300KB

## Checklist

- [ ] WebP with JPEG fallback
- [ ] Responsive srcset
- [ ] Lazy loading below-fold
- [ ] File size <100KB each
- [ ] EXIF removed
