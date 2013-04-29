OOStringRenderer was an attempt to rewrite text rendering in a form closer to
accepted best practices, caching drawable geometry rather than glyph sequences
and using VBOs to store this cache on the GPU where available.

Unfortunately, profiling showed it to be slower than the old immediate mode
code, at least in OS X.

To use this, the follwing steps are needed (broad outline):
* Add OOStringRenderer.m to the project/makefile.
* Remove the functions declared in OOStringRenderer.h from HeadUpDisplay.h/m.
* Import OOStringRenderer.h in HeadUpDisplay.m and a few other files the
  compiler will point out.
* Remove the caching code from OOEncodingConverter.m.
* Ideally, compile with -DOO_USE_VBO=1. As I recall, this causes crashes in
  OOPolygonSprite on some Windows systems.
* Ideally, replace "one-shot" uses of OODrawString() (like the HUD range label
  and FPS counter position line) with OODrawDynamicString().
