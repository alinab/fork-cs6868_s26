	.file	""
	.data
	.globl	_camlPeterson_race$data_begin
_camlPeterson_race$data_begin:
	.text
	.globl	_camlPeterson_race$code_begin
_camlPeterson_race$code_begin:
	nop
	.align	3
	.data
	.align	3
	.data
	.align	3
	.quad	3063
	.globl	_camlPeterson_race$15
_camlPeterson_race$15:
	.quad	_camlPeterson_race$lock_276
	.quad	72057594037927941
	.data
	.align	3
	.quad	3063
	.globl	_camlPeterson_race$14
_camlPeterson_race$14:
	.quad	_camlPeterson_race$unlock_359
	.quad	72057594037927941
	.data
	.align	3
	.quad	3063
	.globl	_camlPeterson_race$13
_camlPeterson_race$13:
	.quad	_camlPeterson_race$thread_work_365
	.quad	72057594037927941
	.data
	.align	3
	.quad	7936
	.globl	_camlPeterson_race
	.globl	_camlPeterson_race
_camlPeterson_race:
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.quad	1
	.data
	.align	3
	.globl	_camlPeterson_race$gc_roots
	.globl	_camlPeterson_race$gc_roots
_camlPeterson_race$gc_roots:
	.quad	_camlPeterson_race
	.quad	0
	.text
	.align	3
	.globl	_camlPeterson_race$lock_276
_camlPeterson_race$lock_276:
	.cfi_startproc
L103:
L104:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #16
	.cfi_adjust_cfa_offset	16
	.ifne (. - L104) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L105:
L102:
	.ifne (. - L105) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L106:
	orr	x0, xzr, #1
	.ifne (. - L106) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L107:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_ml_domain_id
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L107) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L108:
	sub	x3, x0, #2
	.ifne (. - L108) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L109:
	orr	x4, xzr, #4
	.ifne (. - L109) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L110:
	sub	x5, x4, x3
	.ifne (. - L110) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L111:
	adrp	x6, _camlPeterson_race@GOTPAGE
	ldr	x6, [x6, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L111) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L112:
	ldr	x7, [x6, #24]
	.ifne (. - L112) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L113:
	ldr	x8, [x7, #-8]
	.ifne (. - L113) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L114:
	cmp	x3, x8, lsr #9
	b.cs	L115
	.ifne (. - L114) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L117:
	add	x9, x7, x3, lsl #2
	.ifne (. - L117) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L118:
	orr	x10, xzr, #3
	.ifne (. - L118) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L119:
	add	x16, x9, #-4
	stlr	x10, [x16]
	.ifne (. - L119) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L120:
	ldr	x12, [x6, #32]
	.ifne (. - L120) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L121:
	stlr	x3, [x12]
	.ifne (. - L121) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L122:
L101:
	.ifne (. - L122) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L123:
	adrp	x13, _camlPeterson_race@GOTPAGE
	ldr	x13, [x13, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L123) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L124:
	ldr	x14, [x13, #24]
	.ifne (. - L124) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L125:
	ldr	x15, [x14, #-8]
	.ifne (. - L125) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L126:
	cmp	x5, x15, lsr #9
	b.cs	L115
	.ifne (. - L126) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L127:
	add	x19, x14, x5, lsl #2
	.ifne (. - L127) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L128:
	ldr	x20, [x19, #-4]
	.ifne (. - L128) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L129:
	cmp	x20, #1
	b.eq	L100
	.ifne (. - L129) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L130:
	ldr	x22, [x13, #32]
	.ifne (. - L130) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L131:
	ldr	x23, [x22, #0]
	.ifne (. - L131) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L132:
	cmp	x23, x3
	b.ne	L100
	.ifne (. - L132) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L133:
	ldr	x16, [x28, #0]
	cmp	x27, x16
	b.hi	L101
	b	L135
	.ifne (. - L133) - 16
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L136:
L100:
	.ifne (. - L136) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L137:
	orr	x0, xzr, #1
	.ifne (. - L137) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L138:
	.ifne (. - L138) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L139:
	add	sp, sp, #16
	.cfi_adjust_cfa_offset	-16
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	16
	.ifne (. - L139) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L103) - 180
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L135:	bl	_caml_call_gc
L134:	b	L101
L115:	bl	_caml_ml_array_bound_error
L116:
	.cfi_endproc
	.text
	.align	3
	.globl	_camlPeterson_race$unlock_359
_camlPeterson_race$unlock_359:
	.cfi_startproc
L141:
L142:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #16
	.cfi_adjust_cfa_offset	16
	.ifne (. - L142) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L143:
L140:
	.ifne (. - L143) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L144:
	orr	x0, xzr, #1
	.ifne (. - L144) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L145:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_ml_domain_id
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L145) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L146:
	sub	x3, x0, #2
	.ifne (. - L146) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L147:
	adrp	x4, _camlPeterson_race@GOTPAGE
	ldr	x4, [x4, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L147) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L148:
	ldr	x5, [x4, #24]
	.ifne (. - L148) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L149:
	ldr	x6, [x5, #-8]
	.ifne (. - L149) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L150:
	cmp	x3, x6, lsr #9
	b.cs	L151
	.ifne (. - L150) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L153:
	add	x7, x5, x3, lsl #2
	.ifne (. - L153) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L154:
	orr	x8, xzr, #1
	.ifne (. - L154) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L155:
	add	x16, x7, #-4
	stlr	x8, [x16]
	.ifne (. - L155) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L156:
	orr	x0, xzr, #1
	.ifne (. - L156) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L157:
	.ifne (. - L157) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L158:
	add	sp, sp, #16
	.cfi_adjust_cfa_offset	-16
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	16
	.ifne (. - L158) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L141) - 92
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L151:	bl	_caml_ml_array_bound_error
L152:
	.cfi_endproc
	.text
	.align	3
	.globl	_camlPeterson_race$thread_work_365
L162:
	mov	x16, #34
	stp	x16, x30, [sp, #-16]!
	bl	_caml_call_realloc_stack
	ldp	x16, x30, [sp], #16
_camlPeterson_race$thread_work_365:
	.cfi_startproc
	ldr	x16, [x28, #40]
	add	x16, x16, #328
	cmp	sp, x16
	bcc	L162
L163:
L164:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #16
	.cfi_adjust_cfa_offset	16
	.ifne (. - L164) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L165:
L161:
	.ifne (. - L165) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L166:
	orr	x1, xzr, #3
	.ifne (. - L166) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L167:
	movz	x4, #33921, lsl #0
	movk	x4, #30, lsl #16
	.ifne (. - L167) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L168:
	cmp	x1, x4
	b.gt	L159
	.ifne (. - L168) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L169:
	str	x1, [sp, #0]
	.ifne (. - L169) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L170:
L160:
	.ifne (. - L170) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L171:
	orr	x0, xzr, #1
	.ifne (. - L171) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L172:
	bl	_camlPeterson_race$lock_276
L173:
	.ifne (. - L172) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L174:
	adrp	x6, _camlPeterson_race@GOTPAGE
	ldr	x6, [x6, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L174) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L175:
	ldr	x7, [x6, #8]
	.ifne (. - L175) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L176:
	ldr	x8, [x7, #0]
	.ifne (. - L176) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L177:
	add	x9, x8, #2
	.ifne (. - L177) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L178:
	stlr	x9, [x7]
	.ifne (. - L178) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L179:
	orr	x0, xzr, #1
	.ifne (. - L179) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L180:
	bl	_camlPeterson_race$unlock_359
L181:
	.ifne (. - L180) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L182:
	ldr	x12, [sp, #0]
	.ifne (. - L182) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L183:
	mov	x11, x12
	.ifne (. - L183) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L184:
	add	x12, x12, #2
	.ifne (. - L184) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L185:
	str	x12, [sp, #0]
	.ifne (. - L185) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L186:
	movz	x14, #33921, lsl #0
	movk	x14, #30, lsl #16
	.ifne (. - L186) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L187:
	cmp	x11, x14
	b.eq	L159
	.ifne (. - L187) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L188:
	ldr	x16, [x28, #0]
	cmp	x27, x16
	b.hi	L160
	b	L190
	.ifne (. - L188) - 16
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L191:
L159:
	.ifne (. - L191) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L192:
	orr	x0, xzr, #1
	.ifne (. - L192) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L193:
	.ifne (. - L193) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L194:
	add	sp, sp, #16
	.cfi_adjust_cfa_offset	-16
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	16
	.ifne (. - L194) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L163) - 136
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L190:	bl	_caml_call_gc
L189:	b	L160
	.cfi_endproc
	.data
	.align	3
	.quad	4868
	.globl	_camlPeterson_race$9
_camlPeterson_race$9:
	.quad	1
	.quad	1
	.quad	1
	.quad	_camlPeterson_race$8
	.data
	.align	3
	.quad	2827
	.globl	_camlPeterson_race$8
_camlPeterson_race$8:
	.quad	_camlPeterson_race$7
	.quad	1
	.data
	.align	3
	.quad	4092
	.globl	_camlPeterson_race$7
_camlPeterson_race$7:
	.ascii  " (expected: 2_000_000)\12"
	.byte	0
	.data
	.align	3
	.quad	4092
	.globl	_camlPeterson_race$6
_camlPeterson_race$6:
	.ascii  "Final counter value: "
	.space	2
	.byte	2
	.data
	.align	3
	.quad	2816
	.globl	_camlPeterson_race$5
_camlPeterson_race$5:
	.quad	_camlPeterson_race$3
	.quad	_camlPeterson_race$4
	.data
	.align	3
	.quad	9212
	.globl	_camlPeterson_race$4
_camlPeterson_race$4:
	.ascii  "Testing Peterson's lock with 10000 iterations per domain...\12%!"
	.space	1
	.byte	1
	.data
	.align	3
	.quad	2827
	.globl	_camlPeterson_race$3
_camlPeterson_race$3:
	.quad	_camlPeterson_race$1
	.quad	_camlPeterson_race$2
	.data
	.align	3
	.quad	1802
	.globl	_camlPeterson_race$2
_camlPeterson_race$2:
	.quad	1
	.data
	.align	3
	.quad	2816
	.globl	_camlPeterson_race$12
_camlPeterson_race$12:
	.quad	_camlPeterson_race$10
	.quad	_camlPeterson_race$11
	.data
	.align	3
	.quad	7164
	.globl	_camlPeterson_race$11
_camlPeterson_race$11:
	.ascii  "Final counter value: %d (expected: 2_000_000)\12"
	.space	1
	.byte	1
	.data
	.align	3
	.quad	2827
	.globl	_camlPeterson_race$10
_camlPeterson_race$10:
	.quad	_camlPeterson_race$6
	.quad	_camlPeterson_race$9
	.data
	.align	3
	.quad	9212
	.globl	_camlPeterson_race$1
_camlPeterson_race$1:
	.ascii  "Testing Peterson's lock with 10000 iterations per domain...\12"
	.space	3
	.byte	3
	.text
	.align	3
	.globl	_camlPeterson_race$entry
L196:
	mov	x16, #36
	stp	x16, x30, [sp, #-16]!
	bl	_caml_call_realloc_stack
	ldp	x16, x30, [sp], #16
_camlPeterson_race$entry:
	.cfi_startproc
	ldr	x16, [x28, #40]
	add	x16, x16, #344
	cmp	sp, x16
	bcc	L196
L197:
L198:
	str	x30, [sp, #-8]
	.cfi_offset 30, -8
	sub	sp, sp, #32
	.cfi_adjust_cfa_offset	32
	.ifne (. - L198) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L199:
L195:
	.ifne (. - L199) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L200:
	bl	_caml_alloc2
L201:	add	x1, x27, #8
	.ifne (. - L200) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L202:
	orr	x2, xzr, #2048
	.ifne (. - L202) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L203:
	str	x2, [x1, #-8]
	.ifne (. - L203) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L204:
	orr	x2, xzr, #1
	.ifne (. - L204) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L205:
	str	x2, [x1, #0]
	.ifne (. - L205) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L206:
	orr	x3, xzr, #1
	.ifne (. - L206) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L207:
	str	x3, [x1, #8]
	.ifne (. - L207) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L208:
	adrp	x4, _camlPeterson_race@GOTPAGE
	ldr	x4, [x4, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L208) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L209:
	add	x0, x4, #24
	.ifne (. - L209) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L210:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L210) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L211:
	bl	_caml_alloc1
L212:	add	x1, x27, #8
	.ifne (. - L211) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L213:
	orr	x7, xzr, #1024
	.ifne (. - L213) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L214:
	str	x7, [x1, #-8]
	.ifne (. - L214) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L215:
	orr	x8, xzr, #1
	.ifne (. - L215) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L216:
	str	x8, [x1, #0]
	.ifne (. - L216) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L217:
	adrp	x9, _camlPeterson_race@GOTPAGE
	ldr	x9, [x9, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L217) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L218:
	add	x0, x9, #32
	.ifne (. - L218) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L219:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L219) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L220:
	adrp	x1, _camlPeterson_race$15@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race$15@GOTPAGEOFF]
	.ifne (. - L220) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L221:
	adrp	x12, _camlPeterson_race@GOTPAGE
	ldr	x12, [x12, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L221) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L222:
	add	x0, x12, #40
	.ifne (. - L222) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L223:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L223) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L224:
	adrp	x1, _camlPeterson_race$14@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race$14@GOTPAGEOFF]
	.ifne (. - L224) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L225:
	adrp	x15, _camlPeterson_race@GOTPAGE
	ldr	x15, [x15, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L225) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L226:
	add	x0, x15, #48
	.ifne (. - L226) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L227:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L227) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L228:
	movz	x8, #40, lsl #0
	bl	_caml_allocN
L229:	add	x1, x27, #8
	.ifne (. - L228) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L230:
	orr	x21, xzr, #4096
	.ifne (. - L230) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L231:
	str	x21, [x1, #-8]
	.ifne (. - L231) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L232:
	adrp	x0, _camlPeterson_race@GOTPAGE
	ldr	x0, [x0, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L232) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L233:
	ldr	x23, [x0, #24]
	.ifne (. - L233) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L234:
	str	x23, [x1, #0]
	.ifne (. - L234) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L235:
	ldr	x25, [x0, #32]
	.ifne (. - L235) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L236:
	str	x25, [x1, #8]
	.ifne (. - L236) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L237:
	ldr	x2, [x0, #40]
	.ifne (. - L237) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L238:
	str	x2, [x1, #16]
	.ifne (. - L238) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L239:
	ldr	x3, [x0, #48]
	.ifne (. - L239) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L240:
	str	x3, [x1, #24]
	.ifne (. - L240) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L241:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L241) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L242:
	bl	_caml_alloc1
L243:	add	x1, x27, #8
	.ifne (. - L242) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L244:
	orr	x6, xzr, #1024
	.ifne (. - L244) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L245:
	str	x6, [x1, #-8]
	.ifne (. - L245) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L246:
	orr	x7, xzr, #1
	.ifne (. - L246) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L247:
	str	x7, [x1, #0]
	.ifne (. - L247) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L248:
	adrp	x8, _camlPeterson_race@GOTPAGE
	ldr	x8, [x8, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L248) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L249:
	add	x0, x8, #8
	.ifne (. - L249) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L250:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L250) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L251:
	adrp	x1, _camlPeterson_race$13@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race$13@GOTPAGEOFF]
	.ifne (. - L251) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L252:
	adrp	x11, _camlPeterson_race@GOTPAGE
	ldr	x11, [x11, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L252) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L253:
	add	x0, x11, #16
	.ifne (. - L253) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L254:
	mov	x19, sp
	.cfi_remember_state
	.cfi_def_cfa_register 19
	ldr	x16, [x28, 64]
	mov	sp, x16
	bl	_caml_initialize
	mov	sp, x19
	.cfi_restore_state
	.ifne (. - L254) - 20
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L255:
	adrp	x1, _camlPeterson_race$5@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race$5@GOTPAGEOFF]
	.ifne (. - L255) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L256:
	adrp	x14, _camlStdlib@GOTPAGE
	ldr	x14, [x14, _camlStdlib@GOTPAGEOFF]
	.ifne (. - L256) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L257:
	ldr	x0, [x14, #304]
	.ifne (. - L257) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L258:
	bl	_camlStdlib__Printf$fprintf_431
L259:
	.ifne (. - L258) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L260:
	adrp	x19, _camlPeterson_race@GOTPAGE
	ldr	x19, [x19, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L260) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L261:
	ldr	x0, [x19, #16]
	.ifne (. - L261) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L262:
	adrp	x21, _camlStdlib__Domain@GOTPAGE
	ldr	x21, [x21, _camlStdlib__Domain@GOTPAGEOFF]
	.ifne (. - L262) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L263:
	ldr	x1, [x21, #0]
	.ifne (. - L263) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L264:
	bl	_camlStdlib__Domain$spawn_752
L265:
	.ifne (. - L264) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L266:
	str	x0, [sp, #0]
	.ifne (. - L266) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L267:
	adrp	x24, _camlPeterson_race@GOTPAGE
	ldr	x24, [x24, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L267) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L268:
	ldr	x0, [x24, #16]
	.ifne (. - L268) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L269:
	adrp	x1, _camlStdlib__Domain@GOTPAGE
	ldr	x1, [x1, _camlStdlib__Domain@GOTPAGEOFF]
	.ifne (. - L269) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L270:
	ldr	x1, [x1, #0]
	.ifne (. - L270) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L271:
	bl	_camlStdlib__Domain$spawn_752
L272:
	.ifne (. - L271) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L273:
	str	x0, [sp, #8]
	.ifne (. - L273) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L274:
	ldr	x0, [sp, #0]
	.ifne (. - L274) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L275:
	bl	_camlStdlib__Domain$join_764
L276:
	.ifne (. - L275) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L277:
	ldr	x0, [sp, #8]
	.ifne (. - L277) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L278:
	bl	_camlStdlib__Domain$join_764
L279:
	.ifne (. - L278) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L280:
	adrp	x3, _camlPeterson_race@GOTPAGE
	ldr	x3, [x3, _camlPeterson_race@GOTPAGEOFF]
	.ifne (. - L280) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L281:
	ldr	x4, [x3, #8]
	.ifne (. - L281) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L282:
	ldr	x5, [x4, #0]
	.ifne (. - L282) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L283:
	str	x5, [sp, #0]
	.ifne (. - L283) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L284:
	adrp	x1, _camlPeterson_race$12@GOTPAGE
	ldr	x1, [x1, _camlPeterson_race$12@GOTPAGEOFF]
	.ifne (. - L284) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L285:
	adrp	x7, _camlStdlib@GOTPAGE
	ldr	x7, [x7, _camlStdlib@GOTPAGEOFF]
	.ifne (. - L285) - 8
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L286:
	ldr	x0, [x7, #304]
	.ifne (. - L286) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L287:
	bl	_camlStdlib__Printf$fprintf_431
L288:
	.ifne (. - L287) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L289:
	mov	x1, x0
	.ifne (. - L289) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L290:
	ldr	x10, [x1, #0]
	.ifne (. - L290) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L291:
	ldr	x0, [sp, #0]
	.ifne (. - L291) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L292:
	blr	x10
L293:
	.ifne (. - L292) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L294:
	orr	x0, xzr, #1
	.ifne (. - L294) - 4
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L295:
	.ifne (. - L295) - 0
	.error "Emit.instr_size: instruction length mismatch"
	.endif
L296:
	add	sp, sp, #32
	.cfi_adjust_cfa_offset	-32
	ldr	x30, [sp, #-8]
	ret
	.cfi_adjust_cfa_offset	32
	.ifne (. - L296) - 12
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.ifne (. - L197) - 564
	.error "Emit.instr_size: instruction length mismatch"
	.endif
	.cfi_endproc
	.data
	.align	3
	.text
	.globl	_camlPeterson_race$code_end
_camlPeterson_race$code_end:
	.data
	.quad	0
	.globl	_camlPeterson_race$data_end
_camlPeterson_race$data_end:
	.quad	0
	.align	3
	.globl	_camlPeterson_race$frametable
_camlPeterson_race$frametable:
	.quad	17
	.quad	L293
	.short	33
	.short	0
	.align	2
	.long	L297 - . + 0x0
	.align	3
	.quad	L288
	.short	33
	.short	0
	.align	2
	.long	L298 - . + 0x0
	.align	3
	.quad	L279
	.short	33
	.short	0
	.align	2
	.long	L299 - . + 0x0
	.align	3
	.quad	L276
	.short	33
	.short	1
	.short	8
	.align	2
	.long	L300 - . + 0x0
	.align	3
	.quad	L272
	.short	33
	.short	1
	.short	0
	.align	2
	.long	L301 - . + 0x0
	.align	3
	.quad	L265
	.short	33
	.short	0
	.align	2
	.long	L302 - . + 0x0
	.align	3
	.quad	L259
	.short	33
	.short	0
	.align	2
	.long	L298 - . + 0x0
	.align	3
	.quad	L243
	.short	34
	.short	0
	.byte	1
	.byte	0
	.align	3
	.quad	L229
	.short	34
	.short	0
	.byte	1
	.byte	3
	.align	3
	.quad	L212
	.short	34
	.short	0
	.byte	1
	.byte	0
	.align	3
	.quad	L201
	.short	34
	.short	0
	.byte	1
	.byte	1
	.align	3
	.quad	L189
	.short	18
	.short	0
	.byte	0
	.align	3
	.quad	L181
	.short	17
	.short	0
	.align	2
	.long	L303 - . + 0x0
	.align	3
	.quad	L173
	.short	17
	.short	0
	.align	2
	.long	L304 - . + 0x0
	.align	3
	.quad	L152
	.short	17
	.short	0
	.align	2
	.long	L305 - . + 0x0
	.align	3
	.quad	L134
	.short	18
	.short	0
	.byte	0
	.align	3
	.quad	L116
	.short	17
	.short	0
	.align	2
	.long	L306 - . + 0x0
	.align	3
	.align	2
L304:
	.long	L308 - . + 0x0
	.long	0x16810a0
	.align	2
L300:
	.long	L309 - . + 0x0
	.long	0x1b80880
	.align	2
L298:
	.long	L311 - . + 0x0
	.long	0xf84518
	.align	2
L306:
	.long	L312 - . + 0x0
	.long	0xe810a0
	.align	2
L303:
	.long	L308 - . + 0x0
	.long	0x17810b0
	.align	2
L302:
	.long	L309 - . + 0x0
	.long	0x1a82d18
	.align	2
L297:
	.long	L309 - . + 0x0
	.long	0x1d00a50
	.align	2
L299:
	.long	L309 - . + 0x0
	.long	0x1c00880
	.align	2
L305:
	.long	L313 - . + 0x0
	.long	0x13010a8
	.align	2
L301:
	.long	L309 - . + 0x0
	.long	0x1b02d18
L307:
	.asciz	"peterson_race.ml"
L310:
	.asciz	"printf.ml"
	.align	2
L312:
	.long	L307 - . + 0x0
	.asciz	"Peterson_race.Peterson.lock"
	.align	2
L311:
	.long	L310 - . + 0x0
	.asciz	"Stdlib__Printf.printf"
	.align	2
L308:
	.long	L307 - . + 0x0
	.asciz	"Peterson_race.thread_work"
	.align	2
L313:
	.long	L307 - . + 0x0
	.asciz	"Peterson_race.Peterson.unlock"
	.align	2
L309:
	.long	L307 - . + 0x0
	.asciz	"Peterson_race"
	.align	3
