<script setup>
import { getCurrentInstance } from 'vue'
import Wheel from './Wheel.vue'
defineProps({ body: { type: String, default: 'coupe' }, color: String, rim: Object, tire: Object })
const u = 'c' + getCurrentInstance().uid
// b: carrocería, g: vidrios, d: puertas, m: espejo, s: alerón, h: manija
const shapes = {
  coupe: {
    b: 'M18 114C18 100 42 94 72 90L120 62C145 46 205 44 252 50C288 56 312 80 342 88C376 94 388 102 388 114L388 126L18 126Z',
    g: 'M132 66C152 54 204 52 242 56C262 60 280 76 294 86L128 86Z',
    d: 'M186 86L182 122M250 84L254 122', m: [284, 84], s: 'M22 92L52 84L56 89L28 97Z', h: [226, 94],
  },
  gt: {
    b: 'M14 118C14 104 50 98 90 92C130 70 180 56 240 56C290 58 330 80 366 92C384 98 392 106 392 118L392 126L14 126Z',
    g: 'M150 72C180 62 220 60 250 62C276 66 300 80 316 90L140 90Z',
    d: 'M196 90L192 122M262 88L266 122', m: [300, 88], s: 'M16 96L50 88L54 93L22 101Z', h: [236, 96],
  },
  muscle: {
    b: 'M16 116L20 94L108 86L138 56L254 54L292 84L376 90L390 112L390 126L16 126Z',
    g: 'M148 62L246 60L276 84L134 84Z',
    d: 'M190 84L186 122M252 84L256 122', m: [268, 82], s: '', h: [226, 92],
  },
  suv: {
    b: 'M16 112C16 98 30 92 60 88L100 62C110 54 130 50 160 50L290 50C310 50 322 60 336 78L368 88C386 92 392 100 392 112L392 126L16 126Z',
    g: 'M112 66C120 58 134 56 160 56L212 56L212 84L104 84ZM222 56L288 56C300 56 308 64 320 84L222 84Z',
    d: 'M217 56L217 122M300 84L304 122', m: [322, 82], s: '', h: [268, 90],
  },
}
const arch = (cx, r) => `M${cx - r} 120A${r} ${r} 0 0 1 ${cx + r} 120L${cx + r} 126L${cx - r} 126Z`
</script>

<template>
  <svg viewBox="0 0 410 180" class="car-svg" role="img" aria-label="Vista lateral del auto personalizado">
    <defs>
      <linearGradient :id="u + 's'" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#fff" stop-opacity=".5" />
        <stop offset=".25" stop-color="#fff" stop-opacity=".12" />
        <stop offset=".55" stop-color="#000" stop-opacity="0" />
        <stop offset=".85" stop-color="#000" stop-opacity=".3" />
        <stop offset="1" stop-color="#000" stop-opacity=".55" />
      </linearGradient>
      <linearGradient :id="u + 'g'" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#46586a" />
        <stop offset="1" stop-color="#090b0f" />
      </linearGradient>
      <linearGradient :id="u + 'r'" x1="0" y1="0" x2="1" y2=".4">
        <stop offset=".3" stop-color="#fff" stop-opacity="0" />
        <stop offset=".42" stop-color="#fff" stop-opacity=".22" />
        <stop offset=".55" stop-color="#fff" stop-opacity="0" />
      </linearGradient>
      <clipPath :id="u + 'c'">
        <path :d="shapes[body].b" />
        <rect x="0" y="126" width="410" height="60" />
      </clipPath>
    </defs>

    <ellipse cx="205" cy="170" rx="180" ry="8" fill="#000" opacity=".55" />
    <ellipse cx="100" :cy="120 + tire.R" :rx="tire.R + 4" ry="3.5" fill="#000" opacity=".7" />
    <ellipse cx="310" :cy="120 + tire.R" :rx="tire.R + 4" ry="3.5" fill="#000" opacity=".7" />

    <path v-if="shapes[body].s" :d="shapes[body].s" fill="#14171c" />
    <path class="body" :d="shapes[body].b" :fill="color" />
    <path :d="shapes[body].b" :fill="`url(#${u}s)`" />
    <path d="M44 104H372" stroke="#fff" stroke-opacity=".14" stroke-width="1.5" />
    <path d="M44 110H372" stroke="#000" stroke-opacity=".22" stroke-width="1.5" />

    <path :d="shapes[body].g" :fill="`url(#${u}g)`" />
    <path :d="shapes[body].g" :fill="`url(#${u}r)`" />
    <path :d="shapes[body].d" stroke="#000" stroke-opacity=".5" stroke-width="1.4" fill="none" />
    <rect :x="shapes[body].h[0]" :y="shapes[body].h[1]" width="16" height="3" rx="1.5" fill="#000" opacity=".5" />
    <rect :x="shapes[body].m[0]" :y="shapes[body].m[1]" width="14" height="7" rx="3" :fill="color" stroke="#000" stroke-opacity=".45" />
    <rect :x="shapes[body].m[0]" :y="shapes[body].m[1]" width="14" height="7" rx="3" :fill="`url(#${u}s)`" />

    <rect x="110" y="118" width="190" height="8" rx="3" fill="#08080a" opacity=".85" />
    <path d="M360 108L388 108L388 120L364 120Z" fill="#050506" opacity=".9" />
    <path d="M366 111H387M366 114H387M366 117H386" stroke="#26262a" stroke-width="1" />
    <path d="M364 96L387 100L387 105L366 103Z" fill="#0b0b0e" />
    <path d="M368 98.5L384 101.8" stroke="#dff0ff" stroke-width="2" stroke-linecap="round" />
    <circle cx="386" cy="102" r="6" fill="#cfe8ff" opacity=".18" />
    <path d="M16 97L33 98L33 103L16 104Z" fill="#7a0d18" />
    <path d="M18 99.5L32 100.6" stroke="#ff4a5a" stroke-width="1.6" stroke-linecap="round" />
    <ellipse cx="22" cy="121" rx="3.4" ry="2.4" fill="#4a4a50" stroke="#111" />
    <ellipse cx="32" cy="121" rx="3.4" ry="2.4" fill="#4a4a50" stroke="#111" />

    <g :clip-path="`url(#${u}c)`">
      <path :d="arch(100, tire.R + 6)" fill="#050506" />
      <path :d="arch(310, tire.R + 6)" fill="#050506" />
      <g transform="translate(100 120)"><Wheel :key="rim.id + tire.id" :rim="rim" :tire="tire" /></g>
      <g transform="translate(310 120)"><Wheel :key="rim.id + tire.id" :rim="rim" :tire="tire" /></g>
    </g>
  </svg>
</template>