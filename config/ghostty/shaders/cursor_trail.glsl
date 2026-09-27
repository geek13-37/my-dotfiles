// Cursor trail: when the cursor jumps, a tapered smear shrinks from the
// old position into the new one and fades out.

const float DURATION  = 0.18;  // seconds the trail lives
const float OPACITY   = 0.75;  // trail opacity at its start
const float MIN_JUMP  = 0.9;   // jumps shorter than this many line heights leave no trail

// Distance to a segment a->b whose radius goes from ra to rb.
float sdTaper(vec2 p, vec2 a, vec2 b, float ra, float rb) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-4), 0.0, 1.0);
    return length(pa - ba * h) - mix(ra, rb, h);
}

float sdBox(vec2 p, vec2 center, vec2 half_size) {
    vec2 d = abs(p - center) - half_size;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float easeOutCubic(float t) {
    return 1.0 - pow(1.0 - t, 3.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    // .xy is the top-left corner (y grows upwards), .zw is the size
    vec2 cur_half  = iCurrentCursor.zw * 0.5;
    vec2 cur       = iCurrentCursor.xy  + vec2(cur_half.x, -cur_half.y);
    vec2 prev      = iPreviousCursor.xy + vec2(iPreviousCursor.z, -iPreviousCursor.w) * 0.5;

    float t = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    if (t >= 1.0 || distance(cur, prev) < iCurrentCursor.w * MIN_JUMP) return;

    // never paint over the cursor itself
    if (sdBox(fragCoord, cur, cur_half) <= 0.0) return;

    // the tail slides from the old position towards the cursor
    vec2 tail = mix(prev, cur, easeOutCubic(t));
    float head_r = cur_half.y * 0.6;  // by height, so bar/underline cursors get a trail too
    float d = sdTaper(fragCoord, cur, tail, head_r, head_r * 0.25);

    float alpha = (1.0 - smoothstep(-0.5, 0.5, d)) * OPACITY * (1.0 - t);
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb, alpha);
}
