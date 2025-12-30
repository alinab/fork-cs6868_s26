	.file	""
	.data
	.globl	_camlPeterson_race_fixed$data_begin
_camlPeterson_race_fixed$data_begin:
	.text
	.globl	_camlPeterson_race_fixed$code_begin
_camlPeterson_race_fixed$code_begin:
	nop
	.align	3
	.data
	.align	3
	.data
	.align	3
	.quad	3063
	.globl	_camlPeterson_race_fixed$15
_camlPeterson_race_fixed$15:
	.quad	_camlPeterson_race_fixed$lock_298
	.quad	72057594037927941
	.data
	.align	3
	.quad	3063
	.globl	_camlPeterson_race_fixed$14
_camlPeterson_race_fixed$14:
	.quad	_camlPeterson_race_fixed$unlock_381
	.quad	72057594037927941
	.data
	.align	3
	.quad	3063
	.globl	_camlPeterson_race_fixed$13
_camlPeterson_race_fixed$13:
	.quad	_camlPeterson_race_fixed$thread_work_387
	.quad	72057594037927941
	.data
	.align	3
	.quad	7936
	.globl	_camlPeterson_race_fixed
	.globl	_camlPeterson_race_fixed
_camlPeterson_race_fixed:
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.data
	.align	3
	.globl	_camlPeterson_race_fixed$gc_roots
	.globl	_camlPeterson_race_fixed$gc_roots
_camlPeterson_race_fixed$gc_roots:
	.quad	_camlPeterson_race_fixed
	.quad	0
	.text
	.align	3
	.globl	_camlPeterson_race_fixed$lock_298
_camlPeterson_race_fixed$lock_298:
	.cfi_startproc
L107:
L108:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #16
	.cfi_adjust_cfa_offset	16
	.ifne (. - L108) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L109:
L106:
	.ifne (. - L109) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L110:
	orr	x0, xzr, #1
	.ifne (. - L110) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L111:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_ml_domain_id
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L111) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L112:
	sub	x21, x0, #2
	.ifne (. - L112) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L113:
	orr	x5, xzr, #4
	.ifne (. - L113) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L114:
	sub	x20, x5, x21
	.ifne (. - L114) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L115:
	adrp	x6, _camlPeterson_race_fixed@GOTPAGE
	ldr	x6, [x6, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L115) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L116:
	ldr	x7, [x6, #24]
	.ifne (. - L116) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L117:
	ldr	x8, [x7, #-8]
	.ifne (. - L117) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L118:
	cmp	x21, x8, lsr #9
	b.cs	L119
	.ifne (. - L118) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L121:
	and	x9, x8, #255
	.ifne (. - L121) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L122:
	cmp	x9, #254
	b.eq	L105
	.ifne (. - L122) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L123:
	add	x10, x7, x21, lsl #2
	.ifne (. - L123) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L124:
	ldr	x0, [x10, #-4]
	.ifne (. - L124) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L125:
	b	L104
	.ifne (. - L125) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L126:
L105:
	.ifne (. - L126) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L127:
	ldr	x16, [x28, #0]
	sub	x27, x27, #16
	cmp	x27, x16
	b.lo	L130
L129:	add	x0, x27, #8
	.ifne (. - L127) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L131:
	movz	x13, #1277, lsl #0
	.ifne (. - L131) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L132:
	str	x13, [x0, #-8]
	.ifne (. - L132) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L133:
	add	x14, x7, x21, lsl #2
	.ifne (. - L133) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L134:
	ldr	d0, [x14, #-4]
	.ifne (. - L134) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L135:
	str	d0, [x0, #0]
	.ifne (. - L135) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L136:
L104:
	.ifne (. - L136) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L137:
	orr	x2, xzr, #3
	.ifne (. - L137) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L138:
	orr	x1, xzr, #1
	.ifne (. - L138) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L139:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_atomic_exchange_field
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L139) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L140:
	adrp	x22, _camlPeterson_race_fixed@GOTPAGE
	ldr	x22, [x22, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L140) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L141:
	ldr	x0, [x22, #32]
	.ifne (. - L141) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L142:
	orr	x1, xzr, #1
	.ifne (. - L142) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L143:
	mov	x2, x21
	.ifne (. - L143) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L144:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_atomic_exchange_field
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L144) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L145:
L101:
	.ifne (. - L145) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L146:
	adrp	x23, _camlPeterson_race_fixed@GOTPAGE
	ldr	x23, [x23, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L146) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L147:
	ldr	x24, [x23, #24]
	.ifne (. - L147) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L148:
	ldr	x25, [x24, #-8]
	.ifne (. - L148) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L149:
	cmp	x20, x25, lsr #9
	b.cs	L119
	.ifne (. - L149) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L150:
	and	x0, x25, #255
	.ifne (. - L150) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L151:
	cmp	x0, #254
	b.eq	L103
	.ifne (. - L151) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L152:
	add	x1, x24, x20, lsl #2
	.ifne (. - L152) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L153:
	ldr	x2, [x1, #-4]
	.ifne (. - L153) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L154:
	b	L102
	.ifne (. - L154) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L155:
L103:
	.ifne (. - L155) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L156:
	ldr	x16, [x28, #0]
	sub	x27, x27, #16
	cmp	x27, x16
	b.lo	L159
L158:	add	x2, x27, #8
	.ifne (. - L156) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L160:
	movz	x4, #1277, lsl #0
	.ifne (. - L160) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L161:
	str	x4, [x2, #-8]
	.ifne (. - L161) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L162:
	add	x5, x24, x20, lsl #2
	.ifne (. - L162) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L163:
	ldr	d1, [x5, #-4]
	.ifne (. - L163) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L164:
	str	d1, [x2, #0]
	.ifne (. - L164) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L165:
L102:
	.ifne (. - L165) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L166:
	dmb	ishld
	ldar	x6, [x2]
	.ifne (. - L166) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L167:
	cmp	x6, #1
	b.eq	L100
	.ifne (. - L167) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L168:
	adrp	x7, _camlPeterson_race_fixed@GOTPAGE
	ldr	x7, [x7, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L168) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L169:
	ldr	x8, [x7, #32]
	.ifne (. - L169) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L170:
	dmb	ishld
	ldar	x9, [x8]
	.ifne (. - L170) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L171:
	cmp	x9, x21
	b.ne	L100
	.ifne (. - L171) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L172:
	ldr	x16, [x28, #0]
	cmp	x27, x16
	b.hi	L101
	b	L174
	.ifne (. - L172) - 16
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L175:
L100:
	.ifne (. - L175) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L176:
	orr	x0, xzr, #1
	.ifne (. - L176) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L177:
	.ifne (. - L177) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L178:
	add	sp, sp, #16
	.cfi_adjust_cfa_offset	-16
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	16
	.ifne (. - L178) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L107) - 364
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L174:	bl	_caml_call_gc
L173:	b	L101
L159:	bl	_caml_call_gc
L157:	b	L158
L130:	bl	_caml_call_gc
L128:	b	L129
L119:	bl	_caml_ml_array_bound_error
L120:
	.cfi_endproc
	.text
	.align	3
	.globl	_camlPeterson_race_fixed$unlock_381
_camlPeterson_race_fixed$unlock_381:
	.cfi_startproc
L182:
L183:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #16
	.cfi_adjust_cfa_offset	16
	.ifne (. - L183) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L184:
L181:
	.ifne (. - L184) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L185:
	orr	x0, xzr, #1
	.ifne (. - L185) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L186:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_ml_domain_id
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L186) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L187:
	sub	x3, x0, #2
	.ifne (. - L187) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L188:
	adrp	x4, _camlPeterson_race_fixed@GOTPAGE
	ldr	x4, [x4, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L188) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L189:
	ldr	x5, [x4, #24]
	.ifne (. - L189) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L190:
	ldr	x6, [x5, #-8]
	.ifne (. - L190) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L191:
	cmp	x3, x6, lsr #9
	b.cs	L192
	.ifne (. - L191) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L194:
	and	x7, x6, #255
	.ifne (. - L194) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L195:
	cmp	x7, #254
	b.eq	L180
	.ifne (. - L195) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L196:
	add	x8, x5, x3, lsl #2
	.ifne (. - L196) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L197:
	ldr	x0, [x8, #-4]
	.ifne (. - L197) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L198:
	b	L179
	.ifne (. - L198) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L199:
L180:
	.ifne (. - L199) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L200:
	ldr	x16, [x28, #0]
	sub	x27, x27, #16
	cmp	x27, x16
	b.lo	L203
L202:	add	x0, x27, #8
	.ifne (. - L200) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L204:
	movz	x11, #1277, lsl #0
	.ifne (. - L204) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L205:
	str	x11, [x0, #-8]
	.ifne (. - L205) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L206:
	add	x12, x5, x3, lsl #2
	.ifne (. - L206) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L207:
	ldr	d0, [x12, #-4]
	.ifne (. - L207) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L208:
	str	d0, [x0, #0]
	.ifne (. - L208) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L209:
L179:
	.ifne (. - L209) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L210:
	orr	x2, xzr, #1
	.ifne (. - L210) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L211:
	orr	x1, xzr, #1
	.ifne (. - L211) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L212:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_atomic_exchange_field
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L212) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L213:
	orr	x0, xzr, #1
	.ifne (. - L213) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L214:
	.ifne (. - L214) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L215:
	add	sp, sp, #16
	.cfi_adjust_cfa_offset	-16
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	16
	.ifne (. - L215) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L182) - 168
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L203:	bl	_caml_call_gc
L201:	b	L202
L192:	bl	_caml_ml_array_bound_error
L193:
	.cfi_endproc
	.text
	.align	3
	.globl	_camlPeterson_race_fixed$thread_work_387
L219:
	mov	x16, #34
	stp	x16, x30, [sp, #-16]!
	bl	_caml_call_realloc_stack
	ldp	x16, x30, [sp], #16
_camlPeterson_race_fixed$thread_work_387:
	.cfi_startproc
	ldr	x16, [x28, #40]
	add	x16, x16, #328
	cmp	sp, x16
	bcc	L219
L220:
L221:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #16
	.cfi_adjust_cfa_offset	16
	.ifne (. - L221) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L222:
L218:
	.ifne (. - L222) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L223:
	orr	x1, xzr, #3
	.ifne (. - L223) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L224:
	movz	x4, #33921, lsl #0
	movk	x4, #30, lsl #16
	.ifne (. - L224) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L225:
	cmp	x1, x4
	b.gt	L216
	.ifne (. - L225) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L226:
	str	x1, [sp, #0]
	.ifne (. - L226) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L227:
L217:
	.ifne (. - L227) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L228:
	orr	x0, xzr, #1
	.ifne (. - L228) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L229:
	bl	_camlPeterson_race_fixed$lock_298
L230:
	.ifne (. - L229) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L231:
	adrp	x6, _camlPeterson_race_fixed@GOTPAGE
	ldr	x6, [x6, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L231) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L232:
	ldr	x7, [x6, #8]
	.ifne (. - L232) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L233:
	ldr	x8, [x7, #0]
	.ifne (. - L233) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L234:
	add	x9, x8, #2
	.ifne (. - L234) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L235:
	stlr	x9, [x7]
	.ifne (. - L235) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L236:
	orr	x0, xzr, #1
	.ifne (. - L236) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L237:
	bl	_camlPeterson_race_fixed$unlock_381
L238:
	.ifne (. - L237) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L239:
	ldr	x12, [sp, #0]
	.ifne (. - L239) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L240:
	mov	x11, x12
	.ifne (. - L240) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L241:
	add	x12, x12, #2
	.ifne (. - L241) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L242:
	str	x12, [sp, #0]
	.ifne (. - L242) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L243:
	movz	x14, #33921, lsl #0
	movk	x14, #30, lsl #16
	.ifne (. - L243) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L244:
	cmp	x11, x14
	b.eq	L216
	.ifne (. - L244) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L245:
	ldr	x16, [x28, #0]
	cmp	x27, x16
	b.hi	L217
	b	L247
	.ifne (. - L245) - 16
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L248:
L216:
	.ifne (. - L248) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L249:
	orr	x0, xzr, #1
	.ifne (. - L249) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L250:
	.ifne (. - L250) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L251:
	add	sp, sp, #16
	.cfi_adjust_cfa_offset	-16
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	16
	.ifne (. - L251) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L220) - 136
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L247:	bl	_caml_call_gc
L246:	b	L217
	.cfi_endproc
	.data
	.align	3
	.quad	4868
	.globl	_camlPeterson_race_fixed$9
_camlPeterson_race_fixed$9:
	.quad	1
	.quad	1
	.quad	1
	.quad	_camlPeterson_race_fixed$8
	.data
	.align	3
	.quad	2827
	.globl	_camlPeterson_race_fixed$8
_camlPeterson_race_fixed$8:
	.quad	_camlPeterson_race_fixed$7
	.quad	1
	.data
	.align	3
	.quad	4092
	.globl	_camlPeterson_race_fixed$7
_camlPeterson_race_fixed$7:
	.ascii  " (expected: 2_000_000)\12"
	.byte	0
	.data
	.align	3
	.quad	4092
	.globl	_camlPeterson_race_fixed$6
_camlPeterson_race_fixed$6:
	.ascii  "Final counter value: "
	.space	2
	.byte	2
	.data
	.align	3
	.quad	2816
	.globl	_camlPeterson_race_fixed$5
_camlPeterson_race_fixed$5:
	.quad	_camlPeterson_race_fixed$3
	.quad	_camlPeterson_race_fixed$4
	.data
	.align	3
	.quad	9212
	.globl	_camlPeterson_race_fixed$4
_camlPeterson_race_fixed$4:
	.ascii  "Testing Peterson's lock with 10000 iterations per domain...\12%!"
	.space	1
	.byte	1
	.data
	.align	3
	.quad	2827
	.globl	_camlPeterson_race_fixed$3
_camlPeterson_race_fixed$3:
	.quad	_camlPeterson_race_fixed$1
	.quad	_camlPeterson_race_fixed$2
	.data
	.align	3
	.quad	1802
	.globl	_camlPeterson_race_fixed$2
_camlPeterson_race_fixed$2:
	.quad	1
	.data
	.align	3
	.quad	2816
	.globl	_camlPeterson_race_fixed$12
_camlPeterson_race_fixed$12:
	.quad	_camlPeterson_race_fixed$10
	.quad	_camlPeterson_race_fixed$11
	.data
	.align	3
	.quad	7164
	.globl	_camlPeterson_race_fixed$11
_camlPeterson_race_fixed$11:
	.ascii  "Final counter value: %d (expected: 2_000_000)\12"
	.space	1
	.byte	1
	.data
	.align	3
	.quad	2827
	.globl	_camlPeterson_race_fixed$10
_camlPeterson_race_fixed$10:
	.quad	_camlPeterson_race_fixed$6
	.quad	_camlPeterson_race_fixed$9
	.data
	.align	3
	.quad	9212
	.globl	_camlPeterson_race_fixed$1
_camlPeterson_race_fixed$1:
	.ascii  "Testing Peterson's lock with 10000 iterations per domain...\12"
	.space	3
	.byte	3
	.text
	.align	3
	.globl	_camlPeterson_race_fixed$entry
L253:
	mov	x16, #36
	stp	x16, x30, [sp, #-16]!
	bl	_caml_call_realloc_stack
	ldp	x16, x30, [sp], #16
_camlPeterson_race_fixed$entry:
	.cfi_startproc
	ldr	x16, [x28, #40]
	add	x16, x16, #344
	cmp	sp, x16
	bcc	L253
L254:
L255:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #32
	.cfi_adjust_cfa_offset	32
	.ifne (. - L255) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L256:
L252:
	.ifne (. - L256) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L257:
	orr	x8, xzr, #56
	bl	_caml_allocN
L258:	add	x1, x27, #8
	.ifne (. - L257) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L259:
	add	x1, x1, #40
	.ifne (. - L259) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L260:
	orr	x2, xzr, #1024
	.ifne (. - L260) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L261:
	str	x2, [x1, #-8]
	.ifne (. - L261) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L262:
	orr	x2, xzr, #1
	.ifne (. - L262) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L263:
	str	x2, [x1, #0]
	.ifne (. - L263) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L264:
	sub	x3, x1, #16
	.ifne (. - L264) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L265:
	orr	x4, xzr, #1024
	.ifne (. - L265) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L266:
	str	x4, [x3, #-8]
	.ifne (. - L266) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L267:
	orr	x5, xzr, #1
	.ifne (. - L267) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L268:
	str	x5, [x3, #0]
	.ifne (. - L268) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L269:
	sub	x0, x3, #24
	.ifne (. - L269) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L270:
	orr	x7, xzr, #2048
	.ifne (. - L270) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L271:
	str	x7, [x0, #-8]
	.ifne (. - L271) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L272:
	str	x3, [x0, #0]
	.ifne (. - L272) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L273:
	str	x1, [x0, #8]
	.ifne (. - L273) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L274:
	adrp	x8, _caml_array_of_uniform_array@GOTPAGE
	ldr	x8, [x8, _caml_array_of_uniform_array@GOTPAGEOFF]
	bl	_caml_c_call
L275:
	.ifne (. - L274) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L276:
	mov	x1, x0
	.ifne (. - L276) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L277:
	adrp	x9, _camlPeterson_race_fixed@GOTPAGE
	ldr	x9, [x9, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L277) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L278:
	add	x0, x9, #24
	.ifne (. - L278) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L279:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L279) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L280:
	bl	_caml_alloc1
L281:	add	x1, x27, #8
	.ifne (. - L280) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L282:
	orr	x12, xzr, #1024
	.ifne (. - L282) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L283:
	str	x12, [x1, #-8]
	.ifne (. - L283) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L284:
	orr	x13, xzr, #1
	.ifne (. - L284) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L285:
	str	x13, [x1, #0]
	.ifne (. - L285) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L286:
	adrp	x14, _camlPeterson_race_fixed@GOTPAGE
	ldr	x14, [x14, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L286) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L287:
	add	x0, x14, #32
	.ifne (. - L287) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L288:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L288) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L289:
	adrp	x1, _camlPeterson_race_fixed$15@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race_fixed$15@GOTPAGEOFF]
	.ifne (. - L289) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L290:
	adrp	x20, _camlPeterson_race_fixed@GOTPAGE
	ldr	x20, [x20, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L290) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L291:
	add	x0, x20, #40
	.ifne (. - L291) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L292:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L292) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L293:
	adrp	x1, _camlPeterson_race_fixed$14@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race_fixed$14@GOTPAGEOFF]
	.ifne (. - L293) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L294:
	adrp	x23, _camlPeterson_race_fixed@GOTPAGE
	ldr	x23, [x23, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L294) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L295:
	add	x0, x23, #48
	.ifne (. - L295) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L296:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L296) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L297:
	movz	x8, #40, lsl #0
	bl	_caml_allocN
L298:	add	x1, x27, #8
	.ifne (. - L297) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L299:
	orr	x0, xzr, #4096
	.ifne (. - L299) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L300:
	str	x0, [x1, #-8]
	.ifne (. - L300) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L301:
	adrp	x0, _camlPeterson_race_fixed@GOTPAGE
	ldr	x0, [x0, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L301) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L302:
	ldr	x2, [x0, #24]
	.ifne (. - L302) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L303:
	str	x2, [x1, #0]
	.ifne (. - L303) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L304:
	ldr	x4, [x0, #32]
	.ifne (. - L304) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L305:
	str	x4, [x1, #8]
	.ifne (. - L305) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L306:
	ldr	x6, [x0, #40]
	.ifne (. - L306) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L307:
	str	x6, [x1, #16]
	.ifne (. - L307) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L308:
	ldr	x8, [x0, #48]
	.ifne (. - L308) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L309:
	str	x8, [x1, #24]
	.ifne (. - L309) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L310:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L310) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L311:
	bl	_caml_alloc1
L312:	add	x1, x27, #8
	.ifne (. - L311) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L313:
	orr	x11, xzr, #1024
	.ifne (. - L313) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L314:
	str	x11, [x1, #-8]
	.ifne (. - L314) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L315:
	orr	x12, xzr, #1
	.ifne (. - L315) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L316:
	str	x12, [x1, #0]
	.ifne (. - L316) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L317:
	adrp	x13, _camlPeterson_race_fixed@GOTPAGE
	ldr	x13, [x13, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L317) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L318:
	add	x0, x13, #8
	.ifne (. - L318) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L319:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L319) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L320:
	adrp	x1, _camlPeterson_race_fixed$13@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race_fixed$13@GOTPAGEOFF]
	.ifne (. - L320) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L321:
	adrp	x19, _camlPeterson_race_fixed@GOTPAGE
	ldr	x19, [x19, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L321) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L322:
	add	x0, x19, #16
	.ifne (. - L322) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L323:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L323) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L324:
	adrp	x1, _camlPeterson_race_fixed$5@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race_fixed$5@GOTPAGEOFF]
	.ifne (. - L324) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L325:
	adrp	x22, _camlStdlib@GOTPAGE
	ldr	x22, [x22, _camlStdlib@GOTPAGEOFF]
	.ifne (. - L325) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L326:
	ldr	x0, [x22, #304]
	.ifne (. - L326) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L327:
	bl	_camlStdlib__Printf$fprintf_431
L328:
	.ifne (. - L327) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L329:
	adrp	x24, _camlPeterson_race_fixed@GOTPAGE
	ldr	x24, [x24, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L329) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L330:
	ldr	x0, [x24, #16]
	.ifne (. - L330) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L331:
	adrp	x1, _camlStdlib__Domain@GOTPAGE
	ldr	x1, [x1, _camlStdlib__Domain@GOTPAGEOFF]
	.ifne (. - L331) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L332:
	ldr	x1, [x1, #0]
	.ifne (. - L332) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L333:
	bl	_camlStdlib__Domain$spawn_752
L334:
	.ifne (. - L333) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L335:
	str	x0, [sp, #0]
	.ifne (. - L335) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L336:
	adrp	x3, _camlPeterson_race_fixed@GOTPAGE
	ldr	x3, [x3, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L336) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L337:
	ldr	x0, [x3, #16]
	.ifne (. - L337) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L338:
	adrp	x5, _camlStdlib__Domain@GOTPAGE
	ldr	x5, [x5, _camlStdlib__Domain@GOTPAGEOFF]
	.ifne (. - L338) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L339:
	ldr	x1, [x5, #0]
	.ifne (. - L339) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L340:
	bl	_camlStdlib__Domain$spawn_752
L341:
	.ifne (. - L340) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L342:
	str	x0, [sp, #8]
	.ifne (. - L342) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L343:
	ldr	x0, [sp, #0]
	.ifne (. - L343) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L344:
	bl	_camlStdlib__Domain$join_764
L345:
	.ifne (. - L344) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L346:
	ldr	x0, [sp, #8]
	.ifne (. - L346) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L347:
	bl	_camlStdlib__Domain$join_764
L348:
	.ifne (. - L347) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L349:
	adrp	x8, _camlPeterson_race_fixed@GOTPAGE
	ldr	x8, [x8, _camlPeterson_race_fixed@GOTPAGEOFF]
	.ifne (. - L349) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L350:
	ldr	x9, [x8, #8]
	.ifne (. - L350) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L351:
	ldr	x10, [x9, #0]
	.ifne (. - L351) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L352:
	str	x10, [sp, #0]
	.ifne (. - L352) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L353:
	adrp	x1, _camlPeterson_race_fixed$12@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race_fixed$12@GOTPAGEOFF]
	.ifne (. - L353) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L354:
	adrp	x12, _camlStdlib@GOTPAGE
	ldr	x12, [x12, _camlStdlib@GOTPAGEOFF]
	.ifne (. - L354) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L355:
	ldr	x0, [x12, #304]
	.ifne (. - L355) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L356:
	bl	_camlStdlib__Printf$fprintf_431
L357:
	.ifne (. - L356) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L358:
	mov	x1, x0
	.ifne (. - L358) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L359:
	ldr	x15, [x1, #0]
	.ifne (. - L359) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L360:
	ldr	x0, [sp, #0]
	.ifne (. - L360) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L361:
	blr	x15
L362:
	.ifne (. - L361) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L363:
	orr	x0, xzr, #1
	.ifne (. - L363) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L364:
	.ifne (. - L364) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L365:
	add	sp, sp, #32
	.cfi_adjust_cfa_offset	-32
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	32
	.ifne (. - L365) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L254) - 620
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.cfi_endproc
	.data
	.align	3
	.text
	.globl	_camlPeterson_race_fixed$code_end
_camlPeterson_race_fixed$code_end:
	.data
	.quad	0
	.globl	_camlPeterson_race_fixed$data_end
_camlPeterson_race_fixed$data_end:
	.quad	0
	.align	3
	.globl	_camlPeterson_race_fixed$frametable
_camlPeterson_race_fixed$frametable:
	.quad	21
	.quad	L362
	.short	33
	.short	0
	.align	2
	.long	L366 - . + 0x0
	.align	3
	.quad	L357
	.short	33
	.short	0
	.align	2
	.long	L367 - . + 0x0
	.align	3
	.quad	L348
	.short	33
	.short	0
	.align	2
	.long	L368 - . + 0x0
	.align	3
	.quad	L345
	.short	33
	.short	1
	.short	8
	.align	2
	.long	L369 - . + 0x0
	.align	3
	.quad	L341
	.short	33
	.short	1
	.short	0
	.align	2
	.long	L370 - . + 0x0
	.align	3
	.quad	L334
	.short	33
	.short	0
	.align	2
	.long	L371 - . + 0x0
	.align	3
	.quad	L328
	.short	33
	.short	0
	.align	2
	.long	L367 - . + 0x0
	.align	3
	.quad	L312
	.short	34
	.short	0
	.byte	1
	.byte	0
	.align	3
	.quad	L298
	.short	34
	.short	0
	.byte	1
	.byte	3
	.align	3
	.quad	L281
	.short	34
	.short	0
	.byte	1
	.byte	0
	.align	3
	.quad	L275
	.short	33
	.short	0
	.align	2
	.long	L372 - . + 0x0
	.align	3
	.quad	L258
	.short	34
	.short	0
	.byte	3
	.byte	1
	.byte	0
	.byte	0
	.align	3
	.quad	L246
	.short	18
	.short	0
	.byte	0
	.align	3
	.quad	L238
	.short	17
	.short	0
	.align	2
	.long	L373 - . + 0x0
	.align	3
	.quad	L230
	.short	17
	.short	0
	.align	2
	.long	L374 - . + 0x0
	.align	3
	.quad	L201
	.short	18
	.short	1
	.short	11
	.byte	1
	.byte	0
	.align	3
	.quad	L193
	.short	17
	.short	0
	.align	2
	.long	L375 - . + 0x0
	.align	3
	.quad	L173
	.short	18
	.short	0
	.byte	0
	.align	3
	.quad	L157
	.short	18
	.short	1
	.short	43
	.byte	1
	.byte	0
	.align	3
	.quad	L128
	.short	18
	.short	1
	.short	15
	.byte	1
	.byte	0
	.align	3
	.quad	L120
	.short	17
	.short	0
	.align	2
	.long	L376 - . + 0x0
	.align	3
	.align	2
L374:
	.long	L378 - . + 0x0
	.long	0x14010a0
	.align	2
L368:
	.long	L379 - . + 0x0
	.long	0x1980880
	.align	2
L367:
	.long	L381 - . + 0x0
	.long	0xf84518
	.align	2
L372:
	.long	L382 - . + 0x0
	.long	0x9835b8
	.align	2
L370:
	.long	L379 - . + 0x0
	.long	0x1882d18
	.align	2
L375:
	.long	L383 - . + 0x0
	.long	0x1083cb8
	.align	2
L369:
	.long	L379 - . + 0x0
	.long	0x1900880
	.align	2
L366:
	.long	L379 - . + 0x0
	.long	0x1a80a50
	.align	2
L371:
	.long	L379 - . + 0x0
	.long	0x1802d18
	.align	2
L376:
	.long	L384 - . + 0x0
	.long	0xc83cb8
	.align	2
L373:
	.long	L378 - . + 0x0
	.long	0x15010b0
L377:
	.asciz	"peterson_race_fixed.ml"
L380:
	.asciz	"printf.ml"
	.align	2
L383:
	.long	L377 - . + 0x0
	.asciz	"Peterson_race_fixed.Peterson.unlock"
	.align	2
L382:
	.long	L377 - . + 0x0
	.asciz	"Peterson_race_fixed.Peterson.flag"
	.align	2
L384:
	.long	L377 - . + 0x0
	.asciz	"Peterson_race_fixed.Peterson.lock"
	.align	2
L381:
	.long	L380 - . + 0x0
	.asciz	"Stdlib__Printf.printf"
	.align	2
L378:
	.long	L377 - . + 0x0
	.asciz	"Peterson_race_fixed.thread_work"
	.align	2
L379:
	.long	L377 - . + 0x0
	.asciz	"Peterson_race_fixed"
	.align	3
