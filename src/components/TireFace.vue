<script setup>
import { computed, getCurrentInstance } from 'vue'
const props = defineProps({ tire: Object })
const u = 'f' + getCurrentInstance().uid
const T = { sport: { w: 36, h: 14 }, off: { w: 44, h: 34 }, pre: { w: 30, h: 10 } }
const t = computed(() => T[props.tire.id])
const shape = 'M40 52Q200 20 360 52L360 208Q200 240 40 208Z'
</script>

<template>
  <svg viewBox="0 0 400 260" class="car-svg" role="img" :aria-label="'Llanta ' + tire.name">
    <defs>
      <pattern :id="u + 'p'" :width="t.w" :height="t.h" patternUnits="userSpaceOnUse">
        <rect :width="t.w" :height="t.h" fill="#18181b" />
        <path v-if="tire.id === 'sport'" :d="`M0 ${t.h}L${t.w / 2} 3L${t.w} ${t.h}`" fill="none" stroke="#050505" stroke-width="3" />
        <g v-else-if="tire.id === 'off'">
          <rect width="44" height="34" fill="#050505" />
          <rect x="2" y="2" width="18" height="30" rx="3" fill="#202023" />
          <rect x="24" y="2" width="18" height="30" rx="3" fill="#202023" />
        </g>
        <path v-else d="M0 10L30 0" stroke="#070708" stroke-width="2" />
      </pattern>
      <linearGradient :id="u + 's'" x1="0" x2="1" y1="0" y2="0">
        <stop offset="0" stop-color="#000" stop-opacity=".8" />
        <stop offset=".18" stop-color="#000" stop-opacity=".2" />
        <stop offset=".5" stop-color="#fff" stop-opacity=".1" />
        <stop offset=".82" stop-color="#000" stop-opacity=".2" />
        <stop offset="1" stop-color="#000" stop-opacity=".8" />
      </linearGradient>
      <clipPath :id="u + 'c'"><path :d="shape" /></clipPath>
    </defs>
    <ellipse cx="200" cy="248" rx="150" ry="7" fill="#000" opacity=".55" />
    <g :clip-path="`url(#${u}c)`">
      <path :d="shape" :fill="`url(#${u}p)`" />
      <rect v-for="x in [118, 194, 270]" :key="x" :x="x" y="10" width="9" height="240" fill="#030303" />
      <rect x="40" y="10" width="26" height="240" fill="#0f0f11" />
      <rect x="334" y="10" width="26" height="240" fill="#0f0f11" />
      <path :d="shape" :fill="`url(#${u}s)`" />
    </g>
    <path :d="shape" fill="none" stroke="#e11d2e" stroke-width="3" />
  </svg>
</template>