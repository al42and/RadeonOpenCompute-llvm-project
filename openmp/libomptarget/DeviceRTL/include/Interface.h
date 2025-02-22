//===-------- Interface.h - OpenMP interface ---------------------- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Modifications Copyright (c) 2022 Advanced Micro Devices, Inc. All rights reserved.
// Notified per clause 4(b) of the license.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#ifndef OMPTARGET_DEVICERTL_INTERFACE_H
#define OMPTARGET_DEVICERTL_INTERFACE_H

#include "Types.h"

/// External API
///
///{

extern "C" {

/// ICV: dyn-var, constant 0
///
/// setter: ignored.
/// getter: returns 0.
///
///{
void omp_set_dynamic(int);
int omp_get_dynamic(void);
///}

/// ICV: nthreads-var, integer
///
/// scope: data environment
///
/// setter: ignored.
/// getter: returns false.
///
/// implementation notes:
///
///
///{
void omp_set_num_threads(int);
int omp_get_max_threads(void);
///}

/// ICV: thread-limit-var, computed
///
/// getter: returns thread limited defined during launch.
///
///{
int omp_get_thread_limit(void);
///}

/// ICV: max-active-level-var, constant 1
///
/// setter: ignored.
/// getter: returns 1.
///
///{
void omp_set_max_active_levels(int);
int omp_get_max_active_levels(void);
///}

/// ICV: places-partition-var
///
///
///{
///}

/// ICV: active-level-var, 0 or 1
///
/// getter: returns 0 or 1.
///
///{
int omp_get_active_level(void);
///}

/// ICV: level-var
///
/// getter: returns parallel region nesting
///
///{
int omp_get_level(void);
///}

/// ICV: run-sched-var
///
///
///{
void omp_set_schedule(omp_sched_t, int);
void omp_get_schedule(omp_sched_t *, int *);
///}

/// TODO this is incomplete.
int omp_get_num_threads(void);
int omp_get_thread_num(void);
void omp_set_nested(int);

int omp_get_nested(void);

void omp_set_max_active_levels(int Level);

int omp_get_max_active_levels(void);

omp_proc_bind_t omp_get_proc_bind(void);

int omp_get_num_places(void);

int omp_get_place_num_procs(int place_num);

void omp_get_place_proc_ids(int place_num, int *ids);

int omp_get_place_num(void);

int omp_get_partition_num_places(void);

void omp_get_partition_place_nums(int *place_nums);

int omp_get_cancellation(void);

void omp_set_default_device(int deviceId);

int omp_get_default_device(void);

int omp_get_num_devices(void);

int omp_get_device_num(void);

int omp_get_num_teams(void);

int omp_get_team_num();

int omp_get_initial_device(void);

void *llvm_omp_target_dynamic_shared_alloc();

/// Synchronization
///
///{
void omp_init_lock(omp_lock_t *Lock);

void omp_destroy_lock(omp_lock_t *Lock);

void omp_set_lock(omp_lock_t *Lock);

void omp_unset_lock(omp_lock_t *Lock);

int omp_test_lock(omp_lock_t *Lock);
///}

/// Tasking
///
///{
extern "C" {
int omp_in_final(void);

int omp_get_max_task_priority(void);

void omp_fulfill_event(uint64_t);
}
///}

/// Misc
///
///{
double omp_get_wtick(void);

double omp_get_wtime(void);
///}

/// OpenMP 5.1 Memory Management routines (from libomp)
/// OpenMP allocator API is currently unimplemented, including traits.
/// All allocation routines will directly call the global memory allocation
/// routine and, consequently, omp_free will call device memory deallocation.
///
/// {
omp_allocator_handle_t omp_init_allocator(omp_memspace_handle_t m, int ntraits,
                                          omp_alloctrait_t traits[]);

void omp_destroy_allocator(omp_allocator_handle_t allocator);

void omp_set_default_allocator(omp_allocator_handle_t a);

omp_allocator_handle_t omp_get_default_allocator(void);

void *omp_alloc(uint64_t size,
                omp_allocator_handle_t allocator = omp_null_allocator);

void *omp_aligned_alloc(uint64_t align, uint64_t size,
                        omp_allocator_handle_t allocator = omp_null_allocator);

void *omp_calloc(uint64_t nmemb, uint64_t size,
                 omp_allocator_handle_t allocator = omp_null_allocator);

void *omp_aligned_calloc(uint64_t align, uint64_t nmemb, uint64_t size,
                         omp_allocator_handle_t allocator = omp_null_allocator);

void *omp_realloc(void *ptr, uint64_t size,
                  omp_allocator_handle_t allocator = omp_null_allocator,
                  omp_allocator_handle_t free_allocator = omp_null_allocator);

void omp_free(void *ptr, omp_allocator_handle_t allocator = omp_null_allocator);
/// }

/// CUDA exposes a native malloc/free API, while ROCm does not.
//// Any re-definitions of malloc/free delete the native CUDA
//// but they are necessary
#ifdef __AMDGCN__
void *malloc(uint64_t Size);
void free(void *Ptr);
size_t external_get_local_size(uint32_t dim);
size_t external_get_num_groups(uint32_t dim);
#endif
}

extern "C" {
/// Allocate \p Bytes in "shareable" memory and return the address. Needs to be
/// called balanced with __kmpc_free_shared like a stack (push/pop). Can be
/// called by any thread, allocation happens *per thread*.
void *__kmpc_alloc_shared(uint64_t Bytes);

/// Deallocate \p Ptr. Needs to be called balanced with __kmpc_alloc_shared like
/// a stack (push/pop). Can be called by any thread. \p Ptr has to be the
/// allocated by __kmpc_alloc_shared by the same thread.
void __kmpc_free_shared(void *Ptr, uint64_t Bytes);

/// Get a pointer to the memory buffer containing dynamically allocated shared
/// memory configured at launch.
void *__kmpc_get_dynamic_shared();

/// Allocate sufficient space for \p NumArgs sequential `void*` and store the
/// allocation address in \p GlobalArgs.
///
/// Called by the main thread prior to a parallel region.
///
/// We also remember it in GlobalArgsPtr to ensure the worker threads and
/// deallocation function know the allocation address too.
void __kmpc_begin_sharing_variables(void ***GlobalArgs, uint64_t NumArgs);

/// Deallocate the memory allocated by __kmpc_begin_sharing_variables.
///
/// Called by the main thread after a parallel region.
void __kmpc_end_sharing_variables();

/// Store the allocation address obtained via __kmpc_begin_sharing_variables in
/// \p GlobalArgs.
///
/// Called by the worker threads in the parallel region (function).
void __kmpc_get_shared_variables(void ***GlobalArgs);

/// External interface to get the thread ID.
uint32_t __kmpc_get_hardware_thread_id_in_block();

/// External interface to get the number of threads.
uint32_t __kmpc_get_hardware_num_threads_in_block();

/// External interface to get the warp size.
uint32_t __kmpc_get_warp_size();

/// External interface to get the block size
uint32_t __kmpc_get_hardware_num_blocks();

/// Kernel
///
///{
int8_t __kmpc_is_spmd_exec_mode();

int32_t __kmpc_target_init(IdentTy *Ident, int8_t Mode,
                           bool UseGenericStateMachine, bool);

void __kmpc_target_deinit(IdentTy *Ident, int8_t Mode, bool);

///}

/// Reduction
///
///{
void __kmpc_nvptx_end_reduce(int32_t TId);

void __kmpc_nvptx_end_reduce_nowait(int32_t TId);

int32_t __kmpc_nvptx_parallel_reduce_nowait_v2(
    IdentTy *Loc, int32_t TId, int32_t num_vars, uint64_t reduce_size,
    void *reduce_data, ShuffleReductFnTy shflFct, InterWarpCopyFnTy cpyFct);

int32_t __kmpc_nvptx_teams_reduce_nowait_v2(
    IdentTy *Loc, int32_t TId, void *GlobalBuffer, uint32_t num_of_records,
    void *reduce_data, ShuffleReductFnTy shflFct, InterWarpCopyFnTy cpyFct,
    ListGlobalFnTy lgcpyFct, ListGlobalFnTy lgredFct, ListGlobalFnTy glcpyFct,
    ListGlobalFnTy glredFct);
///}

/// Cross team helper functions for special case reductions
///{
///   THESE INTERFACES kmpc_xteam_ WILL BE DEPRACATED AND REPLACED WITH BELOW
///   kmpc_xteamr_
void __kmpc_xteam_sum_d(double, double *);
void __kmpc_xteam_sum_f(float, float *);
void __kmpc_xteam_sum_cd(double _Complex, double _Complex *);
void __kmpc_xteam_sum_cf(float _Complex, float _Complex *);
void __kmpc_xteam_sum_i(int, int *);
void __kmpc_xteam_sum_ui(unsigned int, unsigned int *);
void __kmpc_xteam_sum_l(long int, long int *);
void __kmpc_xteam_sum_ul(unsigned long, unsigned long *);
void __kmpc_xteam_max_d(double, double *);
void __kmpc_xteam_max_f(float, float *);
void __kmpc_xteam_max_i(int, int *);
void __kmpc_xteam_max_ui(unsigned int, unsigned int *);
void __kmpc_xteam_max_l(long int, long int *);
void __kmpc_xteam_max_ul(unsigned long, unsigned long *);
void __kmpc_xteam_min_d(double, double *);
void __kmpc_xteam_min_f(float, float *);
void __kmpc_xteam_min_i(int, int *);
void __kmpc_xteam_min_ui(unsigned int, unsigned int *);
void __kmpc_xteam_min_l(long int, long int *);
void __kmpc_xteam_min_ul(unsigned long, unsigned long *);

#define _RF_LDS volatile __attribute__((address_space(3)))
void __kmpc_rfun_sum_d(double *val, double otherval);
void __kmpc_rfun_sum_lds_d(_RF_LDS double *val, _RF_LDS double *otherval);
void __kmpc_rfun_sum_f(float *val, float otherval);
void __kmpc_rfun_sum_lds_f(_RF_LDS float *val, _RF_LDS float *otherval);
void __kmpc_rfun_sum_i(int *val, int otherval);
void __kmpc_rfun_sum_lds_i(_RF_LDS int *val, _RF_LDS int *otherval);
void __kmpc_rfun_sum_ui(unsigned int *val, unsigned int otherval);
void __kmpc_rfun_sum_lds_ui(_RF_LDS unsigned int *val,
                            _RF_LDS unsigned int *otherval);
void __kmpc_rfun_sum_l(long *val, long otherval);
void __kmpc_rfun_sum_lds_l(_RF_LDS long *val, _RF_LDS long *otherval);
void __kmpc_rfun_sum_ul(unsigned long *val, unsigned long otherval);
void __kmpc_rfun_sum_lds_ul(_RF_LDS unsigned long *val,
                            _RF_LDS unsigned long *otherval);
void __kmpc_rfun_min_d(double *val, double otherval);
void __kmpc_rfun_min_lds_d(_RF_LDS double *val, _RF_LDS double *otherval);
void __kmpc_rfun_min_f(float *val, float otherval);
void __kmpc_rfun_min_lds_f(_RF_LDS float *val, _RF_LDS float *otherval);
void __kmpc_rfun_min_i(int *val, int otherval);
void __kmpc_rfun_min_lds_i(_RF_LDS int *val, _RF_LDS int *otherval);
void __kmpc_rfun_min_ui(unsigned int *val, unsigned int otherval);
void __kmpc_rfun_min_lds_ui(_RF_LDS unsigned int *val,
                            _RF_LDS unsigned int *otherval);
void __kmpc_rfun_min_l(long *val, long otherval);
void __kmpc_rfun_min_lds_l(_RF_LDS long *val, _RF_LDS long *otherval);
void __kmpc_rfun_min_ul(unsigned long *val, unsigned long otherval);
void __kmpc_rfun_min_lds_ul(_RF_LDS unsigned long *val,
                            _RF_LDS unsigned long *otherval);
void __kmpc_rfun_max_d(double *val, double otherval);
void __kmpc_rfun_max_lds_d(_RF_LDS double *val, _RF_LDS double *otherval);
void __kmpc_rfun_max_f(float *val, float otherval);
void __kmpc_rfun_max_lds_f(_RF_LDS float *val, _RF_LDS float *otherval);
void __kmpc_rfun_max_i(int *val, int otherval);
void __kmpc_rfun_max_lds_i(_RF_LDS int *val, _RF_LDS int *otherval);
void __kmpc_rfun_max_ui(unsigned int *val, unsigned int otherval);
void __kmpc_rfun_max_lds_ui(_RF_LDS unsigned int *val,
                            _RF_LDS unsigned int *otherval);
void __kmpc_rfun_max_l(long *val, long otherval);
void __kmpc_rfun_max_lds_l(_RF_LDS long *val, _RF_LDS long *otherval);
void __kmpc_rfun_max_ul(unsigned long *val, unsigned long otherval);
void __kmpc_rfun_max_lds_ul(_RF_LDS unsigned long *val,
                            _RF_LDS unsigned long *otherval);

///  __kmpc_xteamr_<dtype>_<waves>xWSZ: Helper functions for Cross Team
///  reductions
///    <waves> number of warps/waves in thread block
///    WSZ     warp size, so <waves> x WSZ is the team size in threads
///                       example: 16x64 is a teamsize = 1024 threads
///    arg1: the thread local reduction value.
///    arg2: pointer to where result is written.
///    arg3: global array of team values for this reduction instance.
///    arg4: atomic counter of completed teams for this reduction instance.
///    arg5: function pointer to reduction type function (sum,min,max)
///    arg6: function pointer to reduction type function on LDS memory
///    arg7: Initializing value for the reduction type
void __kmpc_xteamr_d_16x64(double v, double *r_ptr, double *tvals,
                           uint32_t *td_ptr, void (*_rf)(double *, double),
                           void (*_rf_lds)(_RF_LDS double *, _RF_LDS double *),
                           double iv);
void __kmpc_xteamr_f_16x64(float v, float *r_ptr, float *tvals,
                           uint32_t *td_ptr, void (*_rf)(float *, float),
                           void (*_rf_lds)(_RF_LDS float *, _RF_LDS float *),
                           float iv);
void __kmpc_xteamr_cd_16x64(double _Complex v, double _Complex  *r_ptr, double _Complex *tvals,
                           uint32_t *td_ptr, void (*_rf)(double _Complex  *, double _Complex),
                           void (*_rf_lds)(_RF_LDS double _Complex *, _RF_LDS double _Complex *),
                           double _Complex iv);
void __kmpc_xteamr_cf_16x64(float _Complex v, float _Complex *r_ptr, float _Complex *tvals,
                           uint32_t *td_ptr, void (*_rf)(float _Complex  *, float _Complex),
                           void (*_rf_lds)(_RF_LDS float _Complex *, _RF_LDS float _Complex *),
                           float _Complex iv);
void __kmpc_xteamr_i_16x64(int v, int *r_ptr, int *tvals, uint32_t *td_ptr,
                           void (*_rf)(int *, int),
                           void (*_rf_lds)(_RF_LDS int *, _RF_LDS int *),
                           int iv);
void __kmpc_xteamr_ui_16x64(uint32_t v, uint32_t *r_ptr, uint32_t *tvals,
                            uint32_t *td_ptr, void (*_rf)(uint32_t *, uint32_t),
                            void (*_rf_lds)(_RF_LDS uint32_t *,
                                            _RF_LDS uint32_t *),
                            uint32_t iv);
void __kmpc_xteamr_l_16x64(long v, long *r_ptr, long *tvals, uint32_t *td_ptr,
                           void (*_rf)(long *, long),
                           void (*_rf_lds)(_RF_LDS long *, _RF_LDS long *),
                           long iv);
void __kmpc_xteamr_ul_16x64(uint64_t v, uint64_t *r_ptr, uint64_t *tvals,
                            uint32_t *td_ptr, void (*_rf)(uint64_t *, uint64_t),
                            void (*_rf_lds)(_RF_LDS uint64_t *,
                                            _RF_LDS uint64_t *),
                            uint64_t iv);
void __kmpc_xteamr_d_8x64(double v, double *r_ptr, double *tvals,
                          uint32_t *td_ptr, void (*_rf)(double *, double),
                          void (*_rf_lds)(_RF_LDS double *, _RF_LDS double *),
                          double iv);
void __kmpc_xteamr_f_8x64(float v, float *r_ptr, float *tvals, uint32_t *td_ptr,
                          void (*_rf)(float *, float),
                          void (*_rf_lds)(_RF_LDS float *, _RF_LDS float *),
                          float iv);
void __kmpc_xteamr_cd_8x64(double _Complex v, double _Complex  *r_ptr, double _Complex *tvals,
                           uint32_t *td_ptr, void (*_rf)(double _Complex  *, double _Complex),
                           void (*_rf_lds)(_RF_LDS double _Complex *, _RF_LDS double _Complex *),
                           double _Complex iv);
void __kmpc_xteamr_cf_8x64(float _Complex v, float _Complex *r_ptr, float _Complex *tvals,
                           uint32_t *td_ptr, void (*_rf)(float _Complex  *, float _Complex),
                           void (*_rf_lds)(_RF_LDS float _Complex *, _RF_LDS float _Complex *),
                           float _Complex iv);
void __kmpc_xteamr_i_8x64(int v, int *r_ptr, int *tvals, uint32_t *td_ptr,
                          void (*_rf)(int *, int),
                          void (*_rf_lds)(_RF_LDS int *, _RF_LDS int *),
                          int iv);
void __kmpc_xteamr_ui_8x64(uint32_t v, uint32_t *r_ptr, uint32_t *tvals,
                           uint32_t *td_ptr, void (*_rf)(uint32_t *, uint32_t),
                           void (*_rf_lds)(_RF_LDS uint32_t *,
                                           _RF_LDS uint32_t *),
                           uint32_t iv);
void __kmpc_xteamr_l_8x64(long v, long *r_ptr, long *tvals, uint32_t *td_ptr,
                          void (*_rf)(long *, long),
                          void (*_rf_lds)(_RF_LDS long *, _RF_LDS long *),
                          long iv);
void __kmpc_xteamr_ul_8x64(uint64_t v, uint64_t *r_ptr, uint64_t *tvals,
                           uint32_t *td_ptr, void (*_rf)(uint64_t *, uint64_t),
                           void (*_rf_lds)(_RF_LDS uint64_t *,
                                           _RF_LDS uint64_t *),
                           uint64_t iv);
void __kmpc_xteamr_d_4x64(double v, double *r_ptr, double *tvals,
                          uint32_t *td_ptr, void (*_rf)(double *, double),
                          void (*_rf_lds)(_RF_LDS double *, _RF_LDS double *),
                          double iv);
void __kmpc_xteamr_f_4x64(float v, float *r_ptr, float *tvals, uint32_t *td_ptr,
                          void (*_rf)(float *, float),
                          void (*_rf_lds)(_RF_LDS float *, _RF_LDS float *),
                          float iv);
void __kmpc_xteamr_i_4x64(int v, int *r_ptr, int *tvals, uint32_t *td_ptr,
                          void (*_rf)(int *, int),
                          void (*_rf_lds)(_RF_LDS int *, _RF_LDS int *),
                          int iv);
void __kmpc_xteamr_ui_4x64(uint32_t v, uint32_t *r_ptr, uint32_t *tvals,
                           uint32_t *td_ptr, void (*_rf)(uint32_t *, uint32_t),
                           void (*_rf_lds)(_RF_LDS uint32_t *,
                                           _RF_LDS uint32_t *),
                           uint32_t iv);
void __kmpc_xteamr_l_4x64(long v, long *r_ptr, long *tvals, uint32_t *td_ptr,
                          void (*_rf)(long *, long),
                          void (*_rf_lds)(_RF_LDS long *, _RF_LDS long *),
                          long iv);
void __kmpc_xteamr_ul_4x64(uint64_t v, uint64_t *r_ptr, uint64_t *tvals,
                           uint32_t *td_ptr, void (*_rf)(uint64_t *, uint64_t),
                           void (*_rf_lds)(_RF_LDS uint64_t *,
                                           _RF_LDS uint64_t *),
                           uint64_t iv);
void __kmpc_xteamr_d_32x32(double v, double *r_ptr, double *tvals,
                           uint32_t *td_ptr, void (*_rf)(double *, double),
                           void (*_rf_lds)(_RF_LDS double *, _RF_LDS double *),
                           double iv);

void __kmpc_xteamr_f_32x32(float v, float *r_ptr, float *tvals,
                           uint32_t *td_ptr, void (*_rf)(float *, float),
                           void (*_rf_lds)(_RF_LDS float *, _RF_LDS float *),
                           float iv);

void __kmpc_xteamr_i_32x32(int v, int *r_ptr, int *tvals, uint32_t *td_ptr,
                           void (*_rf)(int *, int),
                           void (*_rf_lds)(_RF_LDS int *, _RF_LDS int *),
                           int iv);

void __kmpc_xteamr_ui_32x32(uint32_t v, uint32_t *r_ptr, uint32_t *tvals,
                            uint32_t *td_ptr, void (*_rf)(uint32_t *, uint32_t),
                            void (*_rf_lds)(_RF_LDS uint32_t *,
                                            _RF_LDS uint32_t *),
                            uint32_t iv);
void __kmpc_xteamr_l_32x32(long v, long *r_ptr, long *tvals, uint32_t *td_ptr,
                           void (*_rf)(long *, long),
                           void (*_rf_lds)(_RF_LDS long *, _RF_LDS long *),
                           long iv);
void __kmpc_xteamr_ul_32x32(uint64_t v, uint64_t *r_ptr, uint64_t *tvals,
                            uint32_t *td_ptr, void (*_rf)(uint64_t *, uint64_t),
                            void (*_rf_lds)(_RF_LDS uint64_t *,
                                            _RF_LDS uint64_t *),
                            uint64_t iv);
void __kmpc_xteamr_d_16x32(double v, double *r_ptr, double *tvals,
                           uint32_t *td_ptr, void (*_rf)(double *, double),
                           void (*_rf_lds)(_RF_LDS double *, _RF_LDS double *),
                           double iv);

void __kmpc_xteamr_f_16x32(float v, float *r_ptr, float *tvals,
                           uint32_t *td_ptr, void (*_rf)(float *, float),
                           void (*_rf_lds)(_RF_LDS float *, _RF_LDS float *),
                           float iv);

void __kmpc_xteamr_i_16x32(int v, int *r_ptr, int *tvals, uint32_t *td_ptr,
                           void (*_rf)(int *, int),
                           void (*_rf_lds)(_RF_LDS int *, _RF_LDS int *),
                           int iv);
void __kmpc_xteamr_ui_16x32(uint32_t v, uint32_t *r_ptr, uint32_t *tvals,
                            uint32_t *td_ptr, void (*_rf)(uint32_t *, uint32_t),
                            void (*_rf_lds)(_RF_LDS uint32_t *,
                                            _RF_LDS uint32_t *),
                            uint32_t iv);
void __kmpc_xteamr_l_16x32(long v, long *r_ptr, long *tvals, uint32_t *td_ptr,
                           void (*_rf)(long *, long),
                           void (*_rf_lds)(_RF_LDS long *, _RF_LDS long *),
                           long iv);
void __kmpc_xteamr_ul_16x32(uint64_t v, uint64_t *r_ptr, uint64_t *tvals,
                            uint32_t *td_ptr, void (*_rf)(uint64_t *, uint64_t),
                            void (*_rf_lds)(_RF_LDS uint64_t *,
                                            _RF_LDS uint64_t *),
                            uint64_t iv);
void __kmpc_xteamr_d_8x32(double v, double *r_ptr, double *tvals,
                          uint32_t *td_ptr, void (*_rf)(double *, double),
                          void (*_rf_lds)(_RF_LDS double *, _RF_LDS double *),
                          double iv);
void __kmpc_xteamr_f_8x32(float v, float *r_ptr, float *tvals, uint32_t *td_ptr,
                          void (*_rf)(float *, float),
                          void (*_rf_lds)(_RF_LDS float *, _RF_LDS float *),
                          float iv);
void __kmpc_xteamr_i_8x32(int v, int *r_ptr, int *tvals, uint32_t *td_ptr,
                          void (*_rf)(int *, int),
                          void (*_rf_lds)(_RF_LDS int *, _RF_LDS int *),
                          int iv);
void __kmpc_xteamr_ui_8x32(uint32_t v, uint32_t *r_ptr, uint32_t *tvals,
                           uint32_t *td_ptr, void (*_rf)(uint32_t *, uint32_t),
                           void (*_rf_lds)(_RF_LDS uint32_t *,
                                           _RF_LDS uint32_t *),
                           uint32_t iv);
void __kmpc_xteamr_l_8x32(long v, long *r_ptr, long *tvals, uint32_t *td_ptr,
                          void (*_rf)(long *, long),
                          void (*_rf_lds)(_RF_LDS long *, _RF_LDS long *),
                          long iv);
void __kmpc_xteamr_ul_8x32(uint64_t v, uint64_t *r_ptr, uint64_t *tvals,
                           uint32_t *td_ptr, void (*_rf)(uint64_t *, uint64_t),
                           void (*_rf_lds)(_RF_LDS uint64_t *,
                                           _RF_LDS uint64_t *),
                           uint64_t iv);
#undef _RF_LDS

///}

/// Synchronization
///
///{
void __kmpc_ordered(IdentTy *Loc, int32_t TId);

void __kmpc_end_ordered(IdentTy *Loc, int32_t TId);

int32_t __kmpc_cancel_barrier(IdentTy *Loc_ref, int32_t TId);

void __kmpc_barrier(IdentTy *Loc_ref, int32_t TId);

void __kmpc_impl_syncthreads();

void __kmpc_barrier_simple_spmd(IdentTy *Loc_ref, int32_t TId);

void __kmpc_barrier_simple_generic(IdentTy *Loc_ref, int32_t TId);

int32_t __kmpc_master(IdentTy *Loc, int32_t TId);

void __kmpc_end_master(IdentTy *Loc, int32_t TId);

int32_t __kmpc_single(IdentTy *Loc, int32_t TId);

void __kmpc_end_single(IdentTy *Loc, int32_t TId);

void __kmpc_flush(IdentTy *Loc);

void __kmpc_flush_acquire(IdentTy *Loc);

void __kmpc_flush_release(IdentTy *Loc);

void __kmpc_flush_acqrel(IdentTy *Loc);

uint64_t __kmpc_warp_active_thread_mask(void);

void __kmpc_syncwarp(uint64_t Mask);

void __kmpc_critical(IdentTy *Loc, int32_t TId, CriticalNameTy *Name);

void __kmpc_end_critical(IdentTy *Loc, int32_t TId, CriticalNameTy *Name);
///}

/// Parallelism
///
///{
/// TODO
void __kmpc_kernel_prepare_parallel(ParallelRegionFnTy WorkFn);

/// TODO
bool __kmpc_kernel_parallel(ParallelRegionFnTy *WorkFn);

/// TODO
void __kmpc_kernel_end_parallel();

/// TODO
void __kmpc_push_proc_bind(IdentTy *Loc, uint32_t TId, int ProcBind);

/// TODO
void __kmpc_push_num_teams(IdentTy *Loc, int32_t TId, int32_t NumTeams,
                           int32_t ThreadLimit);

/// TODO
uint16_t __kmpc_parallel_level(IdentTy *Loc, uint32_t);

///}

/// Tasking
///
///{
extern "C" {
TaskDescriptorTy *__kmpc_omp_task_alloc(IdentTy *, uint32_t, int32_t,
                                        uint64_t TaskSizeInclPrivateValues,
                                        uint64_t SharedValuesSize,
                                        TaskFnTy TaskFn);

int32_t __kmpc_omp_task(IdentTy *Loc, uint32_t TId,
                        TaskDescriptorTy *TaskDescriptor);

int32_t __kmpc_omp_task_with_deps(IdentTy *Loc, uint32_t TId,
                                  TaskDescriptorTy *TaskDescriptor, int32_t,
                                  void *, int32_t, void *);

void __kmpc_omp_task_begin_if0(IdentTy *Loc, uint32_t TId,
                               TaskDescriptorTy *TaskDescriptor);

void __kmpc_omp_task_complete_if0(IdentTy *Loc, uint32_t TId,
                                  TaskDescriptorTy *TaskDescriptor);

void __kmpc_omp_wait_deps(IdentTy *Loc, uint32_t TId, int32_t, void *, int32_t,
                          void *);

void __kmpc_taskgroup(IdentTy *Loc, uint32_t TId);

void __kmpc_end_taskgroup(IdentTy *Loc, uint32_t TId);

int32_t __kmpc_omp_taskyield(IdentTy *Loc, uint32_t TId, int);

int32_t __kmpc_omp_taskwait(IdentTy *Loc, uint32_t TId);

void __kmpc_taskloop(IdentTy *Loc, uint32_t TId,
                     TaskDescriptorTy *TaskDescriptor, int,
                     uint64_t *LowerBound, uint64_t *UpperBound, int64_t, int,
                     int32_t, uint64_t, void *);

void *__kmpc_task_allow_completion_event(IdentTy *loc_ref,
                                                uint32_t gtid,
                                                TaskDescriptorTy *task);

}
///}

/// Misc
///
///{
int32_t __kmpc_cancellationpoint(IdentTy *Loc, int32_t TId, int32_t CancelVal);

int32_t __kmpc_cancel(IdentTy *Loc, int32_t TId, int32_t CancelVal);
///}

/// Shuffle
///
///{
int32_t __kmpc_shuffle_int32(int32_t val, int16_t delta, int16_t size);
int64_t __kmpc_shuffle_int64(int64_t val, int16_t delta, int16_t size);
///}

/// __init_ThreadDSTPtrPtr is defined in Workshare.cpp to initialize
/// the static LDS global variable ThreadDSTPtrPtr to 0.
/// It is called in Kernel.cpp at the end of initializeRuntime().
void __init_ThreadDSTPtrPtr();
}

/// Extra API exposed by ROCm
extern "C" {
int omp_ext_get_warp_id(void);
int omp_ext_get_lane_id(void);
int omp_ext_get_master_thread_id(void);
int omp_ext_get_smid(void);
int omp_ext_is_spmd_mode(void);
unsigned long long omp_ext_get_active_threads_mask(void);
} // extern "C"

#endif
