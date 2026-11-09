<script setup>
import { computed, getCurrentInstance } from 'vue'
const props = defineProps({ rim: Object, tire: Object })
const u = 'w' + getCurrentInstance().uid
const pol = (r, a) => [r * Math.cos((a * Math.PI) / 180), r * Math.sin((a * Math.PI) / 180)]

const spokes = computed(() => {
  const r = props.tire.rimR - 3, h = 8, s = props.rim.style
  const tp = (wi, wo) => `M${-wi} ${-h}L${-wo} ${-r}L${wo} ${-r}L${wi} ${-h}Z`
  const rot = (n, d, ex = '') => Array.from({ length: n }, (_, i) => ({ d, t: `rotate(${(i * 360) / n}) ${ex}` }))
  if (s === 'five') return rot(5, tp(4, 9))
  if (s === 'multi') return rot(14, tp(1.3, 2.4))
  if (s === 'mesh') return [...rot(10, tp(1.2, 1.8), 'skewX(28)'), ...rot(10, tp(1.2, 1.8), 'skewX(-28)')]
  return rot(10, `M-3 ${-h}C-13 ${-r * 0.5} -3 ${-r * 0.8} -8 ${-r}L2 ${-r}C5 ${-r * 0.7} 6 ${-r * 0.4} 4 ${-h}Z`)
})
const rt = computed(() => (props.tire.R + props.tire.rimR) / 2 + 1.5)
const arc = computed(() => `M${-rt.value} 0A${rt.value} ${rt.value} 0 0 1 ${rt.value} 0`)
const caliper = computed(() => {
  const r = props.tire.rimR * 0.7, [x1, y1] = pol(r, -35), [x2, y2] = pol(r, 20)
  return `M${x1} ${y1}A${r} ${r} 0 0 1 ${x2} ${y2}`
})
const lugs = Array.from({ length: 5 }, (_, i) => pol(5.2, i * 72 - 90))
const dash = computed(() => ({ off: '6 3.5', sport: '3 1.6', pre: '4 2' }[props.tire.id]))
</script>

<template>
  <g class="wheel">
    <defs>
      <radialGradient :id="u + 't'" cx="0" cy="0" :r="tire.R" gradientUnits="userSpaceOnUse">
        <stop :offset="tire.rimR / tire.R" stop-color="#0a0a0b" />
        <stop :offset="(tire.rimR / tire.R + 1) / 2" stop-color="#232326" />
        <stop offset="1" stop-color="#0b0b0c" />
      </radialGradient>
      <linearGradient :id="u + 's'" gradientUnits="userSpaceOnUse" x1="-30" y1="-30" x2="30" y2="30">
        <stop offset="0" stop-color="#fff" stop-opacity=".5" />
        <stop offset=".5" stop-color="#fff" stop-opacity="0" />
        <stop offset="1" stop-color="#000" stop-opacity=".5" />
      </linearGradient>
      <path :id="u + 'p'" :d="arc" />
    </defs>

    <circle :r="tire.R" :fill="`url(#${u}t)`" />
    <circle :r="tire.R - 1" fill="none" stroke="#303034" stroke-width="2.4" :stroke-dasharray="dash" />
    <circle :r="tire.R - 5" fill="none" stroke="#fff" stroke-opacity=".07" />
    <text fill="#8a8a8f" fill-opacity=".6" font-size="4.2" letter-spacing="1.2" text-anchor="middle" font-family="Oswald,sans-serif">
      <textPath :href="'#' + u + 'p'" startOffset="50%">AUTORIM {{ tire.name.toUpperCase() }}</textPath>
    </text>

    <circle :r="tire.rimR + 1.5" fill="#000" />
    <circle :r="tire.rimR" fill="#050506" />
    <circle :r="tire.rimR * 0.8" fill="#5a5c62" />
    <circle :r="tire.rimR * 0.5" fill="#2a2b2f" />
    <circle :r="tire.rimR * 0.68" fill="none" stroke="#1f2023" stroke-width="2.4" stroke-dasharray="1.6 3.2" />
    <path :d="caliper" fill="none" stroke="#b3121f" stroke-width="7" stroke-linecap="round" />
    <path :d="caliper" fill="none" stroke="#ff5a66" stroke-opacity=".5" stroke-width="1.5" stroke-linecap="round" transform="translate(-1 -1.5)" />

    <g v-for="(s, i) in spokes" :key="i" :transform="s.t">
      <path :d="s.d" fill="#000" opacity=".5" transform="translate(1.2 1.6)" />
      <path :d="s.d" :fill="rim.finish" />
      <path :d="s.d" :fill="`url(#${u}s)`" />
    </g>
    <circle v-if="rim.style === 'mesh'" :r="tire.rimR * 0.62" fill="none" :stroke="rim.finish" stroke-width="2.4" />

    <circle :r="tire.rimR - 1" fill="none" :stroke="rim.finish" stroke-width="3.4" />
    <circle :r="tire.rimR - 1" fill="none" :stroke="`url(#${u}s)`" stroke-width="3.4" />
    <circle r="9" :fill="rim.finish" />
    <circle r="9" :fill="`url(#${u}s)`" />
    <circle v-for="(l, i) in lugs" :key="'l' + i" :cx="l[0]" :cy="l[1]" r="1.5" fill="#1b1b1e" stroke="#000" stroke-opacity=".5" stroke-width=".4" />
    <circle r="2.4" fill="#111" />
  </g>
</template>