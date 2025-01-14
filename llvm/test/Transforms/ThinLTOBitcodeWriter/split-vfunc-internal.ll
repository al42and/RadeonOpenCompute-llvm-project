; REQUIRES: x86-registered-target
; RUN: opt --opaque-pointers=0 -thinlto-bc -thinlto-split-lto-unit -o %t %s
; RUN: llvm-modextract --opaque-pointers=0 -b -n 0 -o - %t | llvm-dis --opaque-pointers=0 | FileCheck --check-prefix=M0 %s
; RUN: llvm-modextract --opaque-pointers=0 -b -n 1 -o - %t | llvm-dis --opaque-pointers=0 | FileCheck --check-prefix=M1 %s

target triple = "x86_64-unknown-linux-gnu"

define [1 x i8*]* @source() {
  ret [1 x i8*]* @g
}

; M0: @g.84f59439b469192440047efc8de357fb = external hidden constant [1 x i8*]{{$}}
; M1: @g.84f59439b469192440047efc8de357fb = hidden constant [1 x i8*] [i8* bitcast (i64 (i8*)* @ok.84f59439b469192440047efc8de357fb to i8*)]
@g = internal constant [1 x i8*] [
  i8* bitcast (i64 (i8*)* @ok to i8*)
], !type !0

; M0: define hidden i64 @ok.84f59439b469192440047efc8de357fb
; M1: define available_externally hidden i64 @ok.84f59439b469192440047efc8de357fb
define internal i64 @ok(i8* %this) {
  ret i64 42
}

!0 = !{i32 0, !"typeid"}
