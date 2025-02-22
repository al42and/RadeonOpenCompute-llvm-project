; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse2 | FileCheck %s --check-prefixes=SSE
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx  | FileCheck %s --check-prefixes=AVX1
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2 | FileCheck %s --check-prefixes=AVX2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2,+fast-variable-crosslane-shuffle,+fast-variable-perlane-shuffle | FileCheck %s --check-prefixes=AVX2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2,+fast-variable-perlane-shuffle | FileCheck %s --check-prefixes=AVX2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx512bw,+avx512vl | FileCheck %s --check-prefixes=AVX512

; These patterns are produced by LoopVectorizer for interleaved stores.

define void @store_i64_stride6_vf2(<2 x i64>* %in.vecptr0, <2 x i64>* %in.vecptr1, <2 x i64>* %in.vecptr2, <2 x i64>* %in.vecptr3, <2 x i64>* %in.vecptr4, <2 x i64>* %in.vecptr5, <12 x i64>* %out.vec) nounwind {
; SSE-LABEL: store_i64_stride6_vf2:
; SSE:       # %bb.0:
; SSE-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; SSE-NEXT:    movaps (%rdi), %xmm0
; SSE-NEXT:    movaps (%rsi), %xmm1
; SSE-NEXT:    movaps (%rdx), %xmm2
; SSE-NEXT:    movaps (%rcx), %xmm3
; SSE-NEXT:    movaps (%r8), %xmm4
; SSE-NEXT:    movaps (%r9), %xmm5
; SSE-NEXT:    movaps %xmm0, %xmm6
; SSE-NEXT:    movlhps {{.*#+}} xmm6 = xmm6[0],xmm1[0]
; SSE-NEXT:    movaps %xmm4, %xmm7
; SSE-NEXT:    movlhps {{.*#+}} xmm7 = xmm7[0],xmm5[0]
; SSE-NEXT:    movaps %xmm2, %xmm8
; SSE-NEXT:    unpckhpd {{.*#+}} xmm8 = xmm8[1],xmm3[1]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm4 = xmm4[1],xmm5[1]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1],xmm1[1]
; SSE-NEXT:    movlhps {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE-NEXT:    movaps %xmm2, 16(%rax)
; SSE-NEXT:    movaps %xmm0, 48(%rax)
; SSE-NEXT:    movaps %xmm4, 80(%rax)
; SSE-NEXT:    movaps %xmm8, 64(%rax)
; SSE-NEXT:    movaps %xmm7, 32(%rax)
; SSE-NEXT:    movaps %xmm6, (%rax)
; SSE-NEXT:    retq
;
; AVX1-LABEL: store_i64_stride6_vf2:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX1-NEXT:    vmovaps (%rdi), %xmm0
; AVX1-NEXT:    vmovaps (%rsi), %xmm1
; AVX1-NEXT:    vmovaps (%rdx), %xmm2
; AVX1-NEXT:    vmovaps (%rcx), %xmm3
; AVX1-NEXT:    vmovaps (%r8), %xmm4
; AVX1-NEXT:    vmovaps (%r9), %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm6
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm7
; AVX1-NEXT:    vunpcklpd {{.*#+}} ymm6 = ymm7[0],ymm6[0],ymm7[2],ymm6[2]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm5, %ymm1
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm4, %ymm0
; AVX1-NEXT:    vshufpd {{.*#+}} ymm0 = ymm0[0],ymm1[0],ymm0[3],ymm1[3]
; AVX1-NEXT:    vinsertf128 $1, %xmm5, %ymm3, %ymm1
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm2, %ymm2
; AVX1-NEXT:    vunpckhpd {{.*#+}} ymm1 = ymm2[1],ymm1[1],ymm2[3],ymm1[3]
; AVX1-NEXT:    vmovaps %ymm1, 64(%rax)
; AVX1-NEXT:    vmovapd %ymm0, 32(%rax)
; AVX1-NEXT:    vmovaps %ymm6, (%rax)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: store_i64_stride6_vf2:
; AVX2:       # %bb.0:
; AVX2-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX2-NEXT:    vmovaps (%rdi), %xmm0
; AVX2-NEXT:    vmovaps (%rdx), %xmm1
; AVX2-NEXT:    vmovaps (%r8), %xmm2
; AVX2-NEXT:    vinsertf128 $1, (%rsi), %ymm0, %ymm0
; AVX2-NEXT:    vinsertf128 $1, (%rcx), %ymm1, %ymm1
; AVX2-NEXT:    vinsertf128 $1, (%r9), %ymm2, %ymm2
; AVX2-NEXT:    vunpcklpd {{.*#+}} ymm3 = ymm0[0],ymm1[0],ymm0[2],ymm1[2]
; AVX2-NEXT:    vpermpd {{.*#+}} ymm3 = ymm3[0,2,1,3]
; AVX2-NEXT:    vblendps {{.*#+}} ymm0 = ymm2[0,1],ymm0[2,3],ymm2[4,5],ymm0[6,7]
; AVX2-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vunpckhpd {{.*#+}} ymm1 = ymm1[1],ymm2[1],ymm1[3],ymm2[3]
; AVX2-NEXT:    vpermpd {{.*#+}} ymm1 = ymm1[0,2,1,3]
; AVX2-NEXT:    vmovaps %ymm1, 64(%rax)
; AVX2-NEXT:    vmovaps %ymm0, 32(%rax)
; AVX2-NEXT:    vmovaps %ymm3, (%rax)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: store_i64_stride6_vf2:
; AVX512:       # %bb.0:
; AVX512-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX512-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512-NEXT:    vmovdqa (%rdx), %xmm1
; AVX512-NEXT:    vmovdqa (%r8), %xmm2
; AVX512-NEXT:    vinserti128 $1, (%rcx), %ymm1, %ymm1
; AVX512-NEXT:    vinserti128 $1, (%rsi), %ymm0, %ymm0
; AVX512-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; AVX512-NEXT:    vinserti32x4 $1, (%r9), %zmm2, %zmm1
; AVX512-NEXT:    vmovdqa {{.*#+}} ymm2 = [5,7,9,11]
; AVX512-NEXT:    vpermi2q %zmm1, %zmm0, %zmm2
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm3 = [0,2,4,6,8,10,1,3]
; AVX512-NEXT:    vpermi2q %zmm1, %zmm0, %zmm3
; AVX512-NEXT:    vmovdqu64 %zmm3, (%rax)
; AVX512-NEXT:    vmovdqa %ymm2, 64(%rax)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %in.vec0 = load <2 x i64>, <2 x i64>* %in.vecptr0, align 32
  %in.vec1 = load <2 x i64>, <2 x i64>* %in.vecptr1, align 32
  %in.vec2 = load <2 x i64>, <2 x i64>* %in.vecptr2, align 32
  %in.vec3 = load <2 x i64>, <2 x i64>* %in.vecptr3, align 32
  %in.vec4 = load <2 x i64>, <2 x i64>* %in.vecptr4, align 32
  %in.vec5 = load <2 x i64>, <2 x i64>* %in.vecptr5, align 32

  %concat01 = shufflevector <2 x i64> %in.vec0, <2 x i64> %in.vec1, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %concat23 = shufflevector <2 x i64> %in.vec2, <2 x i64> %in.vec3, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %concat45 = shufflevector <2 x i64> %in.vec4, <2 x i64> %in.vec5, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %concat0123 = shufflevector <4 x i64> %concat01, <4 x i64> %concat23, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %concat45uu = shufflevector <4 x i64> %concat45, <4 x i64> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef>
  %concat012345 = shufflevector <8 x i64> %concat0123, <8 x i64> %concat45uu, <12 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11>
  %interleaved.vec = shufflevector <12 x i64> %concat012345, <12 x i64> poison, <12 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 1, i32 3, i32 5, i32 7, i32 9, i32 11>

  store <12 x i64> %interleaved.vec, <12 x i64>* %out.vec, align 32

  ret void
}

define void @store_i64_stride6_vf4(<4 x i64>* %in.vecptr0, <4 x i64>* %in.vecptr1, <4 x i64>* %in.vecptr2, <4 x i64>* %in.vecptr3, <4 x i64>* %in.vecptr4, <4 x i64>* %in.vecptr5, <24 x i64>* %out.vec) nounwind {
; SSE-LABEL: store_i64_stride6_vf4:
; SSE:       # %bb.0:
; SSE-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; SSE-NEXT:    movaps (%rdi), %xmm2
; SSE-NEXT:    movaps 16(%rdi), %xmm0
; SSE-NEXT:    movaps (%rsi), %xmm5
; SSE-NEXT:    movaps 16(%rsi), %xmm7
; SSE-NEXT:    movaps (%rdx), %xmm6
; SSE-NEXT:    movaps 16(%rdx), %xmm1
; SSE-NEXT:    movaps (%rcx), %xmm8
; SSE-NEXT:    movaps 16(%rcx), %xmm9
; SSE-NEXT:    movaps (%r8), %xmm10
; SSE-NEXT:    movaps 16(%r8), %xmm4
; SSE-NEXT:    movaps (%r9), %xmm11
; SSE-NEXT:    movaps 16(%r9), %xmm12
; SSE-NEXT:    movaps %xmm4, %xmm3
; SSE-NEXT:    unpckhpd {{.*#+}} xmm3 = xmm3[1],xmm12[1]
; SSE-NEXT:    movaps %xmm1, %xmm13
; SSE-NEXT:    unpckhpd {{.*#+}} xmm13 = xmm13[1],xmm9[1]
; SSE-NEXT:    movaps %xmm0, %xmm14
; SSE-NEXT:    unpckhpd {{.*#+}} xmm14 = xmm14[1],xmm7[1]
; SSE-NEXT:    movlhps {{.*#+}} xmm4 = xmm4[0],xmm12[0]
; SSE-NEXT:    movlhps {{.*#+}} xmm1 = xmm1[0],xmm9[0]
; SSE-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm7[0]
; SSE-NEXT:    movaps %xmm10, %xmm7
; SSE-NEXT:    unpckhpd {{.*#+}} xmm7 = xmm7[1],xmm11[1]
; SSE-NEXT:    movaps %xmm6, %xmm9
; SSE-NEXT:    unpckhpd {{.*#+}} xmm9 = xmm9[1],xmm8[1]
; SSE-NEXT:    movaps %xmm2, %xmm12
; SSE-NEXT:    unpckhpd {{.*#+}} xmm12 = xmm12[1],xmm5[1]
; SSE-NEXT:    movlhps {{.*#+}} xmm10 = xmm10[0],xmm11[0]
; SSE-NEXT:    movlhps {{.*#+}} xmm6 = xmm6[0],xmm8[0]
; SSE-NEXT:    movlhps {{.*#+}} xmm2 = xmm2[0],xmm5[0]
; SSE-NEXT:    movaps %xmm2, (%rax)
; SSE-NEXT:    movaps %xmm6, 16(%rax)
; SSE-NEXT:    movaps %xmm10, 32(%rax)
; SSE-NEXT:    movaps %xmm12, 48(%rax)
; SSE-NEXT:    movaps %xmm9, 64(%rax)
; SSE-NEXT:    movaps %xmm7, 80(%rax)
; SSE-NEXT:    movaps %xmm0, 96(%rax)
; SSE-NEXT:    movaps %xmm1, 112(%rax)
; SSE-NEXT:    movaps %xmm4, 128(%rax)
; SSE-NEXT:    movaps %xmm14, 144(%rax)
; SSE-NEXT:    movaps %xmm13, 160(%rax)
; SSE-NEXT:    movaps %xmm3, 176(%rax)
; SSE-NEXT:    retq
;
; AVX1-LABEL: store_i64_stride6_vf4:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX1-NEXT:    vmovapd (%rdi), %ymm0
; AVX1-NEXT:    vmovapd (%rsi), %ymm1
; AVX1-NEXT:    vmovaps (%rdx), %ymm2
; AVX1-NEXT:    vmovapd (%r8), %ymm3
; AVX1-NEXT:    vmovapd (%r9), %ymm4
; AVX1-NEXT:    vmovddup {{.*#+}} xmm5 = mem[0,0]
; AVX1-NEXT:    vmovaps (%rsi), %xmm6
; AVX1-NEXT:    vmovaps (%rdi), %xmm7
; AVX1-NEXT:    vunpckhpd {{.*#+}} xmm8 = xmm7[1],xmm6[1]
; AVX1-NEXT:    vinsertf128 $1, %xmm8, %ymm0, %ymm8
; AVX1-NEXT:    vblendpd {{.*#+}} ymm8 = ymm3[0],ymm8[1,2,3]
; AVX1-NEXT:    vblendpd {{.*#+}} ymm5 = ymm8[0],ymm5[1],ymm8[2,3]
; AVX1-NEXT:    vmovaps (%rcx), %xmm8
; AVX1-NEXT:    vinsertf128 $1, (%r9), %ymm8, %ymm9
; AVX1-NEXT:    vpermilps {{.*#+}} xmm10 = mem[2,3,2,3]
; AVX1-NEXT:    vbroadcastsd 8(%r8), %ymm11
; AVX1-NEXT:    vblendps {{.*#+}} ymm10 = ymm10[0,1,2,3],ymm11[4,5],ymm10[6,7]
; AVX1-NEXT:    vblendps {{.*#+}} ymm9 = ymm10[0,1],ymm9[2,3],ymm10[4,5],ymm9[6,7]
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm10 = ymm4[2,3],ymm1[2,3]
; AVX1-NEXT:    vunpckhpd {{.*#+}} ymm0 = ymm0[1],ymm1[1],ymm0[3],ymm1[3]
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm3[2,3],ymm0[2,3]
; AVX1-NEXT:    vshufpd {{.*#+}} ymm0 = ymm0[0],ymm10[0],ymm0[2],ymm10[3]
; AVX1-NEXT:    vunpcklpd {{.*#+}} ymm1 = ymm2[0],mem[0],ymm2[2],mem[2]
; AVX1-NEXT:    vmovaps 16(%rdi), %xmm2
; AVX1-NEXT:    vunpcklpd {{.*#+}} xmm2 = xmm2[0],mem[0]
; AVX1-NEXT:    vblendps {{.*#+}} ymm1 = ymm2[0,1,2,3],ymm1[4,5,6,7]
; AVX1-NEXT:    vmovapd 16(%rdx), %xmm2
; AVX1-NEXT:    vunpckhpd {{.*#+}} xmm2 = xmm2[1],mem[1]
; AVX1-NEXT:    vbroadcastsd 24(%r8), %ymm3
; AVX1-NEXT:    vblendpd {{.*#+}} ymm2 = ymm2[0,1],ymm3[2],ymm2[3]
; AVX1-NEXT:    vblendpd {{.*#+}} ymm2 = ymm2[0,1,2],ymm4[3]
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm3 = xmm7[0],xmm6[0]
; AVX1-NEXT:    vmovaps (%rdx), %xmm4
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm4 = xmm4[0],xmm8[0]
; AVX1-NEXT:    vmovaps %xmm4, 16(%rax)
; AVX1-NEXT:    vmovaps %xmm3, (%rax)
; AVX1-NEXT:    vmovaps %ymm1, 96(%rax)
; AVX1-NEXT:    vmovapd %ymm0, 128(%rax)
; AVX1-NEXT:    vmovaps %ymm9, 64(%rax)
; AVX1-NEXT:    vmovapd %ymm5, 32(%rax)
; AVX1-NEXT:    vmovapd %ymm2, 160(%rax)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: store_i64_stride6_vf4:
; AVX2:       # %bb.0:
; AVX2-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX2-NEXT:    vmovaps (%rdi), %ymm0
; AVX2-NEXT:    vmovaps (%rsi), %ymm1
; AVX2-NEXT:    vmovaps (%rdx), %ymm2
; AVX2-NEXT:    vmovaps (%rcx), %ymm3
; AVX2-NEXT:    vmovaps (%r8), %ymm4
; AVX2-NEXT:    vmovaps (%r9), %xmm5
; AVX2-NEXT:    vinsertf128 $1, %xmm5, %ymm0, %ymm6
; AVX2-NEXT:    vmovaps (%rcx), %xmm7
; AVX2-NEXT:    vmovaps (%rdx), %xmm8
; AVX2-NEXT:    vunpckhpd {{.*#+}} xmm9 = xmm8[1],xmm7[1]
; AVX2-NEXT:    vbroadcastsd 8(%r8), %ymm10
; AVX2-NEXT:    vblendps {{.*#+}} ymm9 = ymm9[0,1,2,3],ymm10[4,5],ymm9[6,7]
; AVX2-NEXT:    vblendps {{.*#+}} ymm6 = ymm9[0,1,2,3,4,5],ymm6[6,7]
; AVX2-NEXT:    vmovddup {{.*#+}} xmm5 = xmm5[0,0]
; AVX2-NEXT:    vmovaps (%rsi), %xmm9
; AVX2-NEXT:    vmovaps (%rdi), %xmm10
; AVX2-NEXT:    vunpckhpd {{.*#+}} xmm11 = xmm10[1],xmm9[1]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm11 = ymm4[0,1],ymm11[0,1]
; AVX2-NEXT:    vblendps {{.*#+}} ymm5 = ymm11[0,1],ymm5[2,3],ymm11[4,5,6,7]
; AVX2-NEXT:    vunpcklpd {{.*#+}} ymm11 = ymm2[0],ymm3[0],ymm2[2],ymm3[2]
; AVX2-NEXT:    vunpcklpd {{.*#+}} ymm12 = ymm0[0],ymm1[0],ymm0[2],ymm1[2]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm11 = ymm12[2,3],ymm11[2,3]
; AVX2-NEXT:    vunpckhpd {{.*#+}} ymm2 = ymm2[1],ymm3[1],ymm2[3],ymm3[3]
; AVX2-NEXT:    vbroadcastsd 24(%r8), %ymm3
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm2 = ymm2[2,3],ymm3[2,3]
; AVX2-NEXT:    vblendps {{.*#+}} ymm2 = ymm2[0,1,2,3,4,5],mem[6,7]
; AVX2-NEXT:    vunpckhpd {{.*#+}} ymm0 = ymm0[1],ymm1[1],ymm0[3],ymm1[3]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm4[2,3],ymm0[2,3]
; AVX2-NEXT:    vbroadcastsd 16(%r9), %ymm1
; AVX2-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1],ymm1[2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    vmovlhps {{.*#+}} xmm1 = xmm10[0],xmm9[0]
; AVX2-NEXT:    vmovlhps {{.*#+}} xmm3 = xmm8[0],xmm7[0]
; AVX2-NEXT:    vmovaps %xmm3, 16(%rax)
; AVX2-NEXT:    vmovaps %xmm1, (%rax)
; AVX2-NEXT:    vmovaps %ymm11, 96(%rax)
; AVX2-NEXT:    vmovaps %ymm0, 128(%rax)
; AVX2-NEXT:    vmovaps %ymm2, 160(%rax)
; AVX2-NEXT:    vmovaps %ymm5, 32(%rax)
; AVX2-NEXT:    vmovaps %ymm6, 64(%rax)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: store_i64_stride6_vf4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX512-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512-NEXT:    vmovdqa (%rdx), %ymm1
; AVX512-NEXT:    vmovdqa (%r8), %ymm2
; AVX512-NEXT:    vinserti64x4 $1, (%rsi), %zmm0, %zmm0
; AVX512-NEXT:    vinserti64x4 $1, (%rcx), %zmm1, %zmm1
; AVX512-NEXT:    vinserti64x4 $1, (%r9), %zmm2, %zmm2
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm3 = <0,4,8,12,u,u,1,5>
; AVX512-NEXT:    vpermi2q %zmm1, %zmm0, %zmm3
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm4 = [0,1,2,3,8,12,6,7]
; AVX512-NEXT:    vpermi2q %zmm2, %zmm3, %zmm4
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm3 = <1,5,u,u,10,14,2,6>
; AVX512-NEXT:    vpermi2q %zmm0, %zmm1, %zmm3
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm5 = [0,1,9,13,4,5,6,7]
; AVX512-NEXT:    vpermi2q %zmm2, %zmm3, %zmm5
; AVX512-NEXT:    vbroadcasti64x4 {{.*#+}} zmm3 = [11,15,3,7,11,15,3,7]
; AVX512-NEXT:    # zmm3 = mem[0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm1, %zmm0, %zmm3
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm0 = [10,14,2,3,4,5,11,15]
; AVX512-NEXT:    vpermi2q %zmm2, %zmm3, %zmm0
; AVX512-NEXT:    vmovdqu64 %zmm0, 128(%rax)
; AVX512-NEXT:    vmovdqu64 %zmm5, 64(%rax)
; AVX512-NEXT:    vmovdqu64 %zmm4, (%rax)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %in.vec0 = load <4 x i64>, <4 x i64>* %in.vecptr0, align 32
  %in.vec1 = load <4 x i64>, <4 x i64>* %in.vecptr1, align 32
  %in.vec2 = load <4 x i64>, <4 x i64>* %in.vecptr2, align 32
  %in.vec3 = load <4 x i64>, <4 x i64>* %in.vecptr3, align 32
  %in.vec4 = load <4 x i64>, <4 x i64>* %in.vecptr4, align 32
  %in.vec5 = load <4 x i64>, <4 x i64>* %in.vecptr5, align 32

  %concat01 = shufflevector <4 x i64> %in.vec0, <4 x i64> %in.vec1, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %concat23 = shufflevector <4 x i64> %in.vec2, <4 x i64> %in.vec3, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %concat45 = shufflevector <4 x i64> %in.vec4, <4 x i64> %in.vec5, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %concat0123 = shufflevector <8 x i64> %concat01, <8 x i64> %concat23, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %concat45uu = shufflevector <8 x i64> %concat45, <8 x i64> poison, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %concat012345 = shufflevector <16 x i64> %concat0123, <16 x i64> %concat45uu, <24 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  %interleaved.vec = shufflevector <24 x i64> %concat012345, <24 x i64> poison, <24 x i32> <i32 0, i32 4, i32 8, i32 12, i32 16, i32 20, i32 1, i32 5, i32 9, i32 13, i32 17, i32 21, i32 2, i32 6, i32 10, i32 14, i32 18, i32 22, i32 3, i32 7, i32 11, i32 15, i32 19, i32 23>

  store <24 x i64> %interleaved.vec, <24 x i64>* %out.vec, align 32

  ret void
}

define void @store_i64_stride6_vf8(<8 x i64>* %in.vecptr0, <8 x i64>* %in.vecptr1, <8 x i64>* %in.vecptr2, <8 x i64>* %in.vecptr3, <8 x i64>* %in.vecptr4, <8 x i64>* %in.vecptr5, <48 x i64>* %out.vec) nounwind {
; SSE-LABEL: store_i64_stride6_vf8:
; SSE:       # %bb.0:
; SSE-NEXT:    subq $24, %rsp
; SSE-NEXT:    movaps (%rdi), %xmm0
; SSE-NEXT:    movaps 16(%rdi), %xmm1
; SSE-NEXT:    movaps 32(%rdi), %xmm3
; SSE-NEXT:    movaps (%rsi), %xmm9
; SSE-NEXT:    movaps 16(%rsi), %xmm13
; SSE-NEXT:    movaps 32(%rsi), %xmm12
; SSE-NEXT:    movaps (%rdx), %xmm2
; SSE-NEXT:    movaps 16(%rdx), %xmm4
; SSE-NEXT:    movaps 32(%rdx), %xmm7
; SSE-NEXT:    movaps (%rcx), %xmm10
; SSE-NEXT:    movaps 16(%rcx), %xmm14
; SSE-NEXT:    movaps (%r8), %xmm5
; SSE-NEXT:    movaps 16(%r8), %xmm8
; SSE-NEXT:    movaps (%r9), %xmm11
; SSE-NEXT:    movaps 16(%r9), %xmm15
; SSE-NEXT:    movaps %xmm0, %xmm6
; SSE-NEXT:    movlhps {{.*#+}} xmm6 = xmm6[0],xmm9[0]
; SSE-NEXT:    movaps %xmm6, (%rsp) # 16-byte Spill
; SSE-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1],xmm9[1]
; SSE-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps %xmm2, %xmm9
; SSE-NEXT:    movlhps {{.*#+}} xmm9 = xmm9[0],xmm10[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm10[1]
; SSE-NEXT:    movaps %xmm2, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps %xmm5, %xmm10
; SSE-NEXT:    movlhps {{.*#+}} xmm10 = xmm10[0],xmm11[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm5 = xmm5[1],xmm11[1]
; SSE-NEXT:    movaps %xmm5, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps %xmm1, %xmm11
; SSE-NEXT:    movlhps {{.*#+}} xmm11 = xmm11[0],xmm13[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm13[1]
; SSE-NEXT:    movaps %xmm1, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps %xmm4, %xmm13
; SSE-NEXT:    movlhps {{.*#+}} xmm13 = xmm13[0],xmm14[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm4 = xmm4[1],xmm14[1]
; SSE-NEXT:    movaps %xmm4, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps %xmm8, %xmm14
; SSE-NEXT:    movlhps {{.*#+}} xmm14 = xmm14[0],xmm15[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm8 = xmm8[1],xmm15[1]
; SSE-NEXT:    movaps %xmm8, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps %xmm3, %xmm15
; SSE-NEXT:    movlhps {{.*#+}} xmm15 = xmm15[0],xmm12[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm3 = xmm3[1],xmm12[1]
; SSE-NEXT:    movaps %xmm3, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps 32(%rcx), %xmm12
; SSE-NEXT:    movaps %xmm7, %xmm8
; SSE-NEXT:    movlhps {{.*#+}} xmm8 = xmm8[0],xmm12[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm7 = xmm7[1],xmm12[1]
; SSE-NEXT:    movaps %xmm7, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; SSE-NEXT:    movaps 32(%r8), %xmm12
; SSE-NEXT:    movaps 32(%r9), %xmm0
; SSE-NEXT:    movaps %xmm12, %xmm7
; SSE-NEXT:    movlhps {{.*#+}} xmm7 = xmm7[0],xmm0[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm12 = xmm12[1],xmm0[1]
; SSE-NEXT:    movaps 48(%rdi), %xmm5
; SSE-NEXT:    movaps 48(%rsi), %xmm2
; SSE-NEXT:    movaps %xmm5, %xmm6
; SSE-NEXT:    movlhps {{.*#+}} xmm6 = xmm6[0],xmm2[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm5 = xmm5[1],xmm2[1]
; SSE-NEXT:    movaps 48(%rdx), %xmm2
; SSE-NEXT:    movaps 48(%rcx), %xmm3
; SSE-NEXT:    movaps %xmm2, %xmm1
; SSE-NEXT:    movlhps {{.*#+}} xmm1 = xmm1[0],xmm3[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm3[1]
; SSE-NEXT:    movaps 48(%r8), %xmm3
; SSE-NEXT:    movaps 48(%r9), %xmm4
; SSE-NEXT:    movaps %xmm3, %xmm0
; SSE-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm4[0]
; SSE-NEXT:    unpckhpd {{.*#+}} xmm3 = xmm3[1],xmm4[1]
; SSE-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; SSE-NEXT:    movaps %xmm3, 368(%rax)
; SSE-NEXT:    movaps %xmm2, 352(%rax)
; SSE-NEXT:    movaps %xmm5, 336(%rax)
; SSE-NEXT:    movaps %xmm0, 320(%rax)
; SSE-NEXT:    movaps %xmm1, 304(%rax)
; SSE-NEXT:    movaps %xmm6, 288(%rax)
; SSE-NEXT:    movaps %xmm12, 272(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 256(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 240(%rax)
; SSE-NEXT:    movaps %xmm7, 224(%rax)
; SSE-NEXT:    movaps %xmm8, 208(%rax)
; SSE-NEXT:    movaps %xmm15, 192(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 176(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 160(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 144(%rax)
; SSE-NEXT:    movaps %xmm14, 128(%rax)
; SSE-NEXT:    movaps %xmm13, 112(%rax)
; SSE-NEXT:    movaps %xmm11, 96(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 80(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 64(%rax)
; SSE-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, 48(%rax)
; SSE-NEXT:    movaps %xmm10, 32(%rax)
; SSE-NEXT:    movaps %xmm9, 16(%rax)
; SSE-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; SSE-NEXT:    movaps %xmm0, (%rax)
; SSE-NEXT:    addq $24, %rsp
; SSE-NEXT:    retq
;
; AVX1-LABEL: store_i64_stride6_vf8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovapd (%rdi), %ymm7
; AVX1-NEXT:    vmovapd 32(%rdi), %ymm12
; AVX1-NEXT:    vmovapd (%rsi), %ymm9
; AVX1-NEXT:    vmovapd 32(%rsi), %ymm13
; AVX1-NEXT:    vmovapd (%r8), %ymm10
; AVX1-NEXT:    vmovapd 32(%r8), %ymm14
; AVX1-NEXT:    vmovapd 32(%r9), %ymm2
; AVX1-NEXT:    vmovaps 48(%rsi), %xmm0
; AVX1-NEXT:    vmovaps 48(%rdi), %xmm1
; AVX1-NEXT:    vunpcklpd {{.*#+}} ymm0 = ymm1[0],ymm0[0],ymm1[2],ymm0[2]
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1,2,3],mem[4,5],ymm0[6,7]
; AVX1-NEXT:    vbroadcastsd 48(%rcx), %ymm1
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1,2,3,4,5],ymm1[6,7]
; AVX1-NEXT:    vmovups %ymm0, {{[-0-9]+}}(%r{{[sb]}}p) # 32-byte Spill
; AVX1-NEXT:    vmovddup {{.*#+}} xmm1 = mem[0,0]
; AVX1-NEXT:    vmovaps (%rsi), %xmm3
; AVX1-NEXT:    vmovaps 16(%rsi), %xmm5
; AVX1-NEXT:    vmovaps 32(%rsi), %xmm6
; AVX1-NEXT:    vmovaps (%rdi), %xmm4
; AVX1-NEXT:    vmovaps 16(%rdi), %xmm11
; AVX1-NEXT:    vmovaps 32(%rdi), %xmm8
; AVX1-NEXT:    vunpckhpd {{.*#+}} xmm15 = xmm8[1],xmm6[1]
; AVX1-NEXT:    vinsertf128 $1, %xmm15, %ymm0, %ymm15
; AVX1-NEXT:    vblendpd {{.*#+}} ymm15 = ymm14[0],ymm15[1,2,3]
; AVX1-NEXT:    vblendpd {{.*#+}} ymm0 = ymm15[0],ymm1[1],ymm15[2,3]
; AVX1-NEXT:    vmovupd %ymm0, {{[-0-9]+}}(%r{{[sb]}}p) # 32-byte Spill
; AVX1-NEXT:    vunpcklpd {{.*#+}} ymm5 = ymm11[0],ymm5[0],ymm11[2],ymm5[2]
; AVX1-NEXT:    vblendps {{.*#+}} ymm5 = ymm5[0,1,2,3],mem[4,5],ymm5[6,7]
; AVX1-NEXT:    vbroadcastsd 16(%rcx), %ymm11
; AVX1-NEXT:    vblendps {{.*#+}} ymm5 = ymm5[0,1,2,3,4,5],ymm11[6,7]
; AVX1-NEXT:    vmovddup {{.*#+}} xmm11 = mem[0,0]
; AVX1-NEXT:    vunpckhpd {{.*#+}} xmm15 = xmm4[1],xmm3[1]
; AVX1-NEXT:    vinsertf128 $1, %xmm15, %ymm0, %ymm15
; AVX1-NEXT:    vblendpd {{.*#+}} ymm15 = ymm10[0],ymm15[1,2,3]
; AVX1-NEXT:    vblendpd {{.*#+}} ymm11 = ymm15[0],ymm11[1],ymm15[2,3]
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm15 = ymm2[2,3],ymm13[2,3]
; AVX1-NEXT:    vunpckhpd {{.*#+}} ymm12 = ymm12[1],ymm13[1],ymm12[3],ymm13[3]
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm12 = ymm14[2,3],ymm12[2,3]
; AVX1-NEXT:    vshufpd {{.*#+}} ymm12 = ymm12[0],ymm15[0],ymm12[2],ymm15[3]
; AVX1-NEXT:    vmovaps 32(%rcx), %xmm14
; AVX1-NEXT:    vpermilps {{.*#+}} xmm13 = mem[2,3,2,3]
; AVX1-NEXT:    vbroadcastsd 40(%r8), %ymm15
; AVX1-NEXT:    vblendps {{.*#+}} ymm13 = ymm13[0,1,2,3],ymm15[4,5],ymm13[6,7]
; AVX1-NEXT:    vinsertf128 $1, 32(%r9), %ymm14, %ymm15
; AVX1-NEXT:    vblendps {{.*#+}} ymm13 = ymm13[0,1],ymm15[2,3],ymm13[4,5],ymm15[6,7]
; AVX1-NEXT:    vmovapd (%r9), %ymm15
; AVX1-NEXT:    vunpckhpd {{.*#+}} ymm7 = ymm7[1],ymm9[1],ymm7[3],ymm9[3]
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm9 = ymm15[2,3],ymm9[2,3]
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm7 = ymm10[2,3],ymm7[2,3]
; AVX1-NEXT:    vshufpd {{.*#+}} ymm7 = ymm7[0],ymm9[0],ymm7[2],ymm9[3]
; AVX1-NEXT:    vpermilps {{.*#+}} xmm9 = mem[2,3,2,3]
; AVX1-NEXT:    vbroadcastsd 8(%r8), %ymm10
; AVX1-NEXT:    vblendps {{.*#+}} ymm9 = ymm9[0,1,2,3],ymm10[4,5],ymm9[6,7]
; AVX1-NEXT:    vmovaps (%rcx), %xmm10
; AVX1-NEXT:    vinsertf128 $1, (%r9), %ymm10, %ymm0
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm9[0,1],ymm0[2,3],ymm9[4,5],ymm0[6,7]
; AVX1-NEXT:    vmovapd 48(%rdx), %xmm9
; AVX1-NEXT:    vunpckhpd {{.*#+}} xmm9 = xmm9[1],mem[1]
; AVX1-NEXT:    vbroadcastsd 56(%r8), %ymm1
; AVX1-NEXT:    vblendpd {{.*#+}} ymm1 = ymm9[0,1],ymm1[2],ymm9[3]
; AVX1-NEXT:    vblendpd {{.*#+}} ymm1 = ymm1[0,1,2],ymm2[3]
; AVX1-NEXT:    vmovapd 16(%rdx), %xmm2
; AVX1-NEXT:    vunpckhpd {{.*#+}} xmm2 = xmm2[1],mem[1]
; AVX1-NEXT:    vbroadcastsd 24(%r8), %ymm9
; AVX1-NEXT:    vblendpd {{.*#+}} ymm2 = ymm2[0,1],ymm9[2],ymm2[3]
; AVX1-NEXT:    vblendpd {{.*#+}} ymm2 = ymm2[0,1,2],ymm15[3]
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm6 = xmm8[0],xmm6[0]
; AVX1-NEXT:    vmovaps 32(%rdx), %xmm8
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm8 = xmm8[0],xmm14[0]
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm3 = xmm4[0],xmm3[0]
; AVX1-NEXT:    vmovaps (%rdx), %xmm4
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm4 = xmm4[0],xmm10[0]
; AVX1-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX1-NEXT:    vmovaps %xmm4, 16(%rax)
; AVX1-NEXT:    vmovaps %xmm3, (%rax)
; AVX1-NEXT:    vmovaps %xmm8, 208(%rax)
; AVX1-NEXT:    vmovaps %xmm6, 192(%rax)
; AVX1-NEXT:    vmovaps %ymm0, 64(%rax)
; AVX1-NEXT:    vmovapd %ymm7, 128(%rax)
; AVX1-NEXT:    vmovaps %ymm13, 256(%rax)
; AVX1-NEXT:    vmovapd %ymm12, 320(%rax)
; AVX1-NEXT:    vmovapd %ymm11, 32(%rax)
; AVX1-NEXT:    vmovaps %ymm5, 96(%rax)
; AVX1-NEXT:    vmovapd %ymm2, 160(%rax)
; AVX1-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %ymm0 # 32-byte Reload
; AVX1-NEXT:    vmovaps %ymm0, 224(%rax)
; AVX1-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %ymm0 # 32-byte Reload
; AVX1-NEXT:    vmovaps %ymm0, 288(%rax)
; AVX1-NEXT:    vmovapd %ymm1, 352(%rax)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: store_i64_stride6_vf8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    pushq %rax
; AVX2-NEXT:    vmovaps 32(%rdx), %ymm7
; AVX2-NEXT:    vmovaps (%r8), %ymm4
; AVX2-NEXT:    vmovaps 32(%r8), %ymm13
; AVX2-NEXT:    vmovaps (%r9), %xmm14
; AVX2-NEXT:    vmovaps 32(%r9), %xmm6
; AVX2-NEXT:    vinsertf128 $1, %xmm6, %ymm0, %ymm0
; AVX2-NEXT:    vmovaps (%rcx), %xmm1
; AVX2-NEXT:    vmovaps %xmm1, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; AVX2-NEXT:    vmovaps 32(%rcx), %xmm3
; AVX2-NEXT:    vmovaps (%rdx), %xmm2
; AVX2-NEXT:    vmovaps %xmm2, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; AVX2-NEXT:    vmovaps 32(%rdx), %xmm5
; AVX2-NEXT:    vunpckhpd {{.*#+}} xmm8 = xmm5[1],xmm3[1]
; AVX2-NEXT:    vbroadcastsd 40(%r8), %ymm9
; AVX2-NEXT:    vblendps {{.*#+}} ymm8 = ymm8[0,1,2,3],ymm9[4,5],ymm8[6,7]
; AVX2-NEXT:    vblendps {{.*#+}} ymm0 = ymm8[0,1,2,3,4,5],ymm0[6,7]
; AVX2-NEXT:    vmovups %ymm0, {{[-0-9]+}}(%r{{[sb]}}p) # 32-byte Spill
; AVX2-NEXT:    vmovddup {{.*#+}} xmm6 = xmm6[0,0]
; AVX2-NEXT:    vmovaps (%rsi), %xmm8
; AVX2-NEXT:    vmovaps 32(%rsi), %xmm11
; AVX2-NEXT:    vmovaps (%rdi), %xmm10
; AVX2-NEXT:    vmovaps 32(%rdi), %xmm12
; AVX2-NEXT:    vunpckhpd {{.*#+}} xmm9 = xmm12[1],xmm11[1]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm9 = ymm13[0,1],ymm9[0,1]
; AVX2-NEXT:    vblendps {{.*#+}} ymm0 = ymm9[0,1],ymm6[2,3],ymm9[4,5,6,7]
; AVX2-NEXT:    vmovups %ymm0, {{[-0-9]+}}(%r{{[sb]}}p) # 32-byte Spill
; AVX2-NEXT:    vunpckhpd {{.*#+}} xmm9 = xmm2[1],xmm1[1]
; AVX2-NEXT:    vbroadcastsd 8(%r8), %ymm15
; AVX2-NEXT:    vblendps {{.*#+}} ymm9 = ymm9[0,1,2,3],ymm15[4,5],ymm9[6,7]
; AVX2-NEXT:    vinsertf128 $1, %xmm14, %ymm0, %ymm15
; AVX2-NEXT:    vblendps {{.*#+}} ymm0 = ymm9[0,1,2,3,4,5],ymm15[6,7]
; AVX2-NEXT:    vmovups %ymm0, {{[-0-9]+}}(%r{{[sb]}}p) # 32-byte Spill
; AVX2-NEXT:    vmovddup {{.*#+}} xmm14 = xmm14[0,0]
; AVX2-NEXT:    vunpckhpd {{.*#+}} xmm15 = xmm10[1],xmm8[1]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm15 = ymm4[0,1],ymm15[0,1]
; AVX2-NEXT:    vblendps {{.*#+}} ymm14 = ymm15[0,1],ymm14[2,3],ymm15[4,5,6,7]
; AVX2-NEXT:    vunpckhpd {{.*#+}} ymm15 = ymm7[1],mem[1],ymm7[3],mem[3]
; AVX2-NEXT:    vbroadcastsd 56(%r8), %ymm0
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm2 = ymm15[2,3],ymm0[2,3]
; AVX2-NEXT:    vmovaps 32(%rdi), %ymm15
; AVX2-NEXT:    vmovaps 32(%rsi), %ymm0
; AVX2-NEXT:    vunpckhpd {{.*#+}} ymm6 = ymm15[1],ymm0[1],ymm15[3],ymm0[3]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm6 = ymm13[2,3],ymm6[2,3]
; AVX2-NEXT:    vbroadcastsd 48(%r9), %ymm13
; AVX2-NEXT:    vblendps {{.*#+}} ymm6 = ymm6[0,1],ymm13[2,3],ymm6[4,5,6,7]
; AVX2-NEXT:    vunpcklpd {{.*#+}} ymm0 = ymm15[0],ymm0[0],ymm15[2],ymm0[2]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm7[2,3]
; AVX2-NEXT:    vbroadcastsd 48(%rcx), %ymm7
; AVX2-NEXT:    vblendps {{.*#+}} ymm1 = ymm0[0,1,2,3,4,5],ymm7[6,7]
; AVX2-NEXT:    vmovaps (%rdx), %ymm7
; AVX2-NEXT:    vunpckhpd {{.*#+}} ymm13 = ymm7[1],mem[1],ymm7[3],mem[3]
; AVX2-NEXT:    vbroadcastsd 24(%r8), %ymm15
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm13 = ymm13[2,3],ymm15[2,3]
; AVX2-NEXT:    vmovaps (%rdi), %ymm15
; AVX2-NEXT:    vmovaps (%rsi), %ymm0
; AVX2-NEXT:    vunpckhpd {{.*#+}} ymm9 = ymm15[1],ymm0[1],ymm15[3],ymm0[3]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm4 = ymm4[2,3],ymm9[2,3]
; AVX2-NEXT:    vbroadcastsd 16(%r9), %ymm9
; AVX2-NEXT:    vblendps {{.*#+}} ymm4 = ymm4[0,1],ymm9[2,3],ymm4[4,5,6,7]
; AVX2-NEXT:    vunpcklpd {{.*#+}} ymm0 = ymm15[0],ymm0[0],ymm15[2],ymm0[2]
; AVX2-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3],ymm7[2,3]
; AVX2-NEXT:    vbroadcastsd 16(%rcx), %ymm7
; AVX2-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1,2,3,4,5],ymm7[6,7]
; AVX2-NEXT:    vmovlhps {{.*#+}} xmm7 = xmm12[0],xmm11[0]
; AVX2-NEXT:    vmovlhps {{.*#+}} xmm3 = xmm5[0],xmm3[0]
; AVX2-NEXT:    vmovlhps {{.*#+}} xmm5 = xmm10[0],xmm8[0]
; AVX2-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm8 # 16-byte Reload
; AVX2-NEXT:    vunpcklpd {{[-0-9]+}}(%r{{[sb]}}p), %xmm8, %xmm8 # 16-byte Folded Reload
; AVX2-NEXT:    # xmm8 = xmm8[0],mem[0]
; AVX2-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX2-NEXT:    vblendps {{.*#+}} ymm2 = ymm2[0,1,2,3,4,5],mem[6,7]
; AVX2-NEXT:    vblendps {{.*#+}} ymm9 = ymm13[0,1,2,3,4,5],mem[6,7]
; AVX2-NEXT:    vmovaps %xmm8, 16(%rax)
; AVX2-NEXT:    vmovaps %xmm5, (%rax)
; AVX2-NEXT:    vmovaps %xmm3, 208(%rax)
; AVX2-NEXT:    vmovaps %xmm7, 192(%rax)
; AVX2-NEXT:    vmovaps %ymm0, 96(%rax)
; AVX2-NEXT:    vmovaps %ymm4, 128(%rax)
; AVX2-NEXT:    vmovaps %ymm9, 160(%rax)
; AVX2-NEXT:    vmovaps %ymm1, 288(%rax)
; AVX2-NEXT:    vmovaps %ymm6, 320(%rax)
; AVX2-NEXT:    vmovaps %ymm2, 352(%rax)
; AVX2-NEXT:    vmovaps %ymm14, 32(%rax)
; AVX2-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %ymm0 # 32-byte Reload
; AVX2-NEXT:    vmovaps %ymm0, 64(%rax)
; AVX2-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %ymm0 # 32-byte Reload
; AVX2-NEXT:    vmovaps %ymm0, 224(%rax)
; AVX2-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %ymm0 # 32-byte Reload
; AVX2-NEXT:    vmovaps %ymm0, 256(%rax)
; AVX2-NEXT:    popq %rax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: store_i64_stride6_vf8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; AVX512-NEXT:    vmovdqu64 (%rdi), %zmm4
; AVX512-NEXT:    vmovdqu64 (%rsi), %zmm6
; AVX512-NEXT:    vmovdqu64 (%rdx), %zmm2
; AVX512-NEXT:    vmovdqu64 (%rcx), %zmm3
; AVX512-NEXT:    vmovdqu64 (%r8), %zmm1
; AVX512-NEXT:    vbroadcasti64x4 {{.*#+}} zmm0 = [4,12,5,13,4,12,5,13]
; AVX512-NEXT:    # zmm0 = mem[0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm6, %zmm4, %zmm0
; AVX512-NEXT:    vmovdqa {{.*#+}} ymm5 = <u,u,4,12>
; AVX512-NEXT:    vpermi2q %zmm3, %zmm2, %zmm5
; AVX512-NEXT:    movb $12, %r10b
; AVX512-NEXT:    kmovd %r10d, %k1
; AVX512-NEXT:    vmovdqa64 %zmm5, %zmm0 {%k1}
; AVX512-NEXT:    movb $16, %r10b
; AVX512-NEXT:    kmovd %r10d, %k2
; AVX512-NEXT:    vmovdqa64 %zmm1, %zmm0 {%k2}
; AVX512-NEXT:    vmovdqu64 (%r9), %zmm5
; AVX512-NEXT:    vbroadcasti32x4 {{.*#+}} zmm7 = [2,10,2,10,2,10,2,10]
; AVX512-NEXT:    # zmm7 = mem[0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm6, %zmm4, %zmm7
; AVX512-NEXT:    vbroadcasti64x4 {{.*#+}} zmm8 = [1,9,2,10,1,9,2,10]
; AVX512-NEXT:    # zmm8 = mem[0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm3, %zmm2, %zmm8
; AVX512-NEXT:    movb $48, %r9b
; AVX512-NEXT:    kmovd %r9d, %k2
; AVX512-NEXT:    vmovdqa64 %zmm7, %zmm8 {%k2}
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm7 = <0,1,9,u,4,5,6,7>
; AVX512-NEXT:    vpermi2q %zmm1, %zmm8, %zmm7
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm8 = [0,1,2,9,4,5,6,7]
; AVX512-NEXT:    vpermi2q %zmm5, %zmm7, %zmm8
; AVX512-NEXT:    vbroadcasti32x4 {{.*#+}} zmm7 = [6,14,6,14,6,14,6,14]
; AVX512-NEXT:    # zmm7 = mem[0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm6, %zmm4, %zmm7
; AVX512-NEXT:    vbroadcasti64x4 {{.*#+}} zmm9 = [5,13,6,14,5,13,6,14]
; AVX512-NEXT:    # zmm9 = mem[0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm3, %zmm2, %zmm9
; AVX512-NEXT:    vmovdqa64 %zmm7, %zmm9 {%k2}
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm7 = <0,1,13,u,4,5,6,7>
; AVX512-NEXT:    vpermi2q %zmm1, %zmm9, %zmm7
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm9 = [0,1,2,13,4,5,6,7]
; AVX512-NEXT:    vpermi2q %zmm5, %zmm7, %zmm9
; AVX512-NEXT:    vbroadcasti64x4 {{.*#+}} zmm7 = [0,8,1,9,0,8,1,9]
; AVX512-NEXT:    # zmm7 = mem[0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm6, %zmm4, %zmm7
; AVX512-NEXT:    vmovdqa (%rdx), %xmm10
; AVX512-NEXT:    vpunpcklqdq {{.*#+}} xmm10 = xmm10[0],mem[0]
; AVX512-NEXT:    vinserti128 $1, %xmm10, %ymm0, %ymm10
; AVX512-NEXT:    vinserti64x4 $0, %ymm10, %zmm0, %zmm7 {%k1}
; AVX512-NEXT:    vinserti32x4 $2, (%r8), %zmm7, %zmm7
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm10 = [0,1,2,3,4,8,6,7]
; AVX512-NEXT:    vpermi2q %zmm5, %zmm7, %zmm10
; AVX512-NEXT:    vbroadcasti32x4 {{.*#+}} zmm7 = [7,15,7,15,7,15,7,15]
; AVX512-NEXT:    # zmm7 = mem[0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm3, %zmm2, %zmm7
; AVX512-NEXT:    vmovdqa {{.*#+}} ymm11 = <u,u,7,15>
; AVX512-NEXT:    vpermi2q %zmm6, %zmm4, %zmm11
; AVX512-NEXT:    vshufi64x2 {{.*#+}} zmm4 = zmm11[0,1,2,3],zmm7[4,5,6,7]
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm6 = <14,u,2,3,4,5,15,u>
; AVX512-NEXT:    vpermi2q %zmm1, %zmm4, %zmm6
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm4 = [0,14,2,3,4,5,6,15]
; AVX512-NEXT:    vpermi2q %zmm5, %zmm6, %zmm4
; AVX512-NEXT:    vbroadcasti32x4 {{.*#+}} zmm6 = [3,11,3,11,3,11,3,11]
; AVX512-NEXT:    # zmm6 = mem[0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3]
; AVX512-NEXT:    vpermi2q %zmm3, %zmm2, %zmm6
; AVX512-NEXT:    vmovdqa (%rdi), %ymm2
; AVX512-NEXT:    vpunpckhqdq {{.*#+}} ymm2 = ymm2[1],mem[1],ymm2[3],mem[3]
; AVX512-NEXT:    vinserti64x4 $0, %ymm2, %zmm6, %zmm2
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm3 = <10,u,2,3,4,5,11,u>
; AVX512-NEXT:    vpermi2q %zmm1, %zmm2, %zmm3
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm1 = [0,10,2,3,4,5,6,11]
; AVX512-NEXT:    vpermi2q %zmm5, %zmm3, %zmm1
; AVX512-NEXT:    vmovdqa64 {{.*#+}} zmm2 = [0,1,2,3,4,12,6,7]
; AVX512-NEXT:    vpermi2q %zmm5, %zmm0, %zmm2
; AVX512-NEXT:    vmovdqu64 %zmm2, 192(%rax)
; AVX512-NEXT:    vmovdqu64 %zmm1, 128(%rax)
; AVX512-NEXT:    vmovdqu64 %zmm4, 320(%rax)
; AVX512-NEXT:    vmovdqu64 %zmm9, 256(%rax)
; AVX512-NEXT:    vmovdqu64 %zmm8, 64(%rax)
; AVX512-NEXT:    vmovdqu64 %zmm10, (%rax)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %in.vec0 = load <8 x i64>, <8 x i64>* %in.vecptr0, align 32
  %in.vec1 = load <8 x i64>, <8 x i64>* %in.vecptr1, align 32
  %in.vec2 = load <8 x i64>, <8 x i64>* %in.vecptr2, align 32
  %in.vec3 = load <8 x i64>, <8 x i64>* %in.vecptr3, align 32
  %in.vec4 = load <8 x i64>, <8 x i64>* %in.vecptr4, align 32
  %in.vec5 = load <8 x i64>, <8 x i64>* %in.vecptr5, align 32

  %concat01 = shufflevector <8 x i64> %in.vec0, <8 x i64> %in.vec1, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %concat23 = shufflevector <8 x i64> %in.vec2, <8 x i64> %in.vec3, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %concat45 = shufflevector <8 x i64> %in.vec4, <8 x i64> %in.vec5, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %concat0123 = shufflevector <16 x i64> %concat01, <16 x i64> %concat23, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %concat45uu = shufflevector <16 x i64> %concat45, <16 x i64> poison, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %concat012345 = shufflevector <32 x i64> %concat0123, <32 x i64> %concat45uu, <48 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47>
  %interleaved.vec = shufflevector <48 x i64> %concat012345, <48 x i64> poison, <48 x i32> <i32 0, i32 8, i32 16, i32 24, i32 32, i32 40, i32 1, i32 9, i32 17, i32 25, i32 33, i32 41, i32 2, i32 10, i32 18, i32 26, i32 34, i32 42, i32 3, i32 11, i32 19, i32 27, i32 35, i32 43, i32 4, i32 12, i32 20, i32 28, i32 36, i32 44, i32 5, i32 13, i32 21, i32 29, i32 37, i32 45, i32 6, i32 14, i32 22, i32 30, i32 38, i32 46, i32 7, i32 15, i32 23, i32 31, i32 39, i32 47>

  store <48 x i64> %interleaved.vec, <48 x i64>* %out.vec, align 32

  ret void
}
