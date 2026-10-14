// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"

void Vtop___024root___eval_triggers_vec__ico(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_triggers_vec__ico\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(vlSelfRef.__VicoFirstIteration)));
}

bool Vtop___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___trigger_anySet__ico\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___ico_sequent__TOP__0\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.lc_alu__DOT__i_alu_op = vlSelfRef.i_alu_op;
    vlSelfRef.lc_alu__DOT__i_op_a = vlSelfRef.i_op_a;
    vlSelfRef.lc_alu__DOT__i_op_b = vlSelfRef.i_op_b;
    vlSelfRef.lc_alu__DOT__o_eq = (vlSelfRef.lc_alu__DOT__i_op_a 
                                   == vlSelfRef.lc_alu__DOT__i_op_b);
    vlSelfRef.lc_alu__DOT__o_lt = VL_LTS_III(32, vlSelfRef.lc_alu__DOT__i_op_a, vlSelfRef.lc_alu__DOT__i_op_b);
    vlSelfRef.lc_alu__DOT__o_ltu = (vlSelfRef.lc_alu__DOT__i_op_a 
                                    < vlSelfRef.lc_alu__DOT__i_op_b);
    vlSelfRef.o_eq = vlSelfRef.lc_alu__DOT__o_eq;
    vlSelfRef.o_lt = vlSelfRef.lc_alu__DOT__o_lt;
    vlSelfRef.o_ltu = vlSelfRef.lc_alu__DOT__o_ltu;
    vlSelfRef.lc_alu__DOT__o_alu_result = ((8U & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                            ? ((4U 
                                                & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                ? (
                                                   (2U 
                                                    & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                    ? 0U
                                                    : 
                                                   ((1U 
                                                     & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                     ? 
                                                    VL_SHIFTRS_III(32,32,5, vlSelfRef.lc_alu__DOT__i_op_a, 
                                                                   (0x0000001fU 
                                                                    & vlSelfRef.lc_alu__DOT__i_op_b))
                                                     : 0U))
                                                : (
                                                   (2U 
                                                    & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                    ? 0U
                                                    : 
                                                   ((1U 
                                                     & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                     ? 0U
                                                     : 
                                                    (vlSelfRef.lc_alu__DOT__i_op_a 
                                                     - vlSelfRef.lc_alu__DOT__i_op_b))))
                                            : ((4U 
                                                & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                ? (
                                                   (2U 
                                                    & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                    ? 
                                                   ((1U 
                                                     & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                     ? 
                                                    (vlSelfRef.lc_alu__DOT__i_op_a 
                                                     & vlSelfRef.lc_alu__DOT__i_op_b)
                                                     : 
                                                    (vlSelfRef.lc_alu__DOT__i_op_a 
                                                     | vlSelfRef.lc_alu__DOT__i_op_b))
                                                    : 
                                                   ((1U 
                                                     & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                     ? 
                                                    (vlSelfRef.lc_alu__DOT__i_op_a 
                                                     >> 
                                                     (0x0000001fU 
                                                      & vlSelfRef.lc_alu__DOT__i_op_b))
                                                     : 
                                                    (vlSelfRef.lc_alu__DOT__i_op_a 
                                                     ^ vlSelfRef.lc_alu__DOT__i_op_b)))
                                                : (
                                                   (2U 
                                                    & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                    ? 
                                                   ((1U 
                                                     & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                     ? (IData)(vlSelfRef.lc_alu__DOT__o_ltu)
                                                     : (IData)(vlSelfRef.lc_alu__DOT__o_lt))
                                                    : 
                                                   ((1U 
                                                     & (IData)(vlSelfRef.lc_alu__DOT__i_alu_op))
                                                     ? 
                                                    (vlSelfRef.lc_alu__DOT__i_op_a 
                                                     << 
                                                     (0x0000001fU 
                                                      & vlSelfRef.lc_alu__DOT__i_op_b))
                                                     : 
                                                    (vlSelfRef.lc_alu__DOT__i_op_a 
                                                     + vlSelfRef.lc_alu__DOT__i_op_b)))));
    vlSelfRef.o_alu_result = vlSelfRef.lc_alu__DOT__o_alu_result;
}

void Vtop___024root___eval_ico(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_ico\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered[0U])) {
        Vtop___024root___ico_sequent__TOP__0(vlSelf);
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtop___024root___eval_phase__ico(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__ico\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VicoExecute;
    // Body
    Vtop___024root___eval_triggers_vec__ico(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtop___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    __VicoExecute = Vtop___024root___trigger_anySet__ico(vlSelfRef.__VicoTriggered);
    if (__VicoExecute) {
        Vtop___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Vtop___024root___eval(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VicoIterCount;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VicoIterCount)))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
            VL_FATAL_MT("/home/thanh-le/work/LanternCore/ip/core/tests/test_alu/../../rtl/lc_alu.sv", 4, "", "DIDNOTCONVERGE: Input combinational region did not converge after '--converge-limit' of 100 tries");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        vlSelfRef.__VicoPhaseResult = Vtop___024root___eval_phase__ico(vlSelf);
        vlSelfRef.__VicoFirstIteration = 0U;
    } while (vlSelfRef.__VicoPhaseResult);
}

#ifdef VL_DEBUG
void Vtop___024root___eval_debug_assertions(Vtop___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_debug_assertions\n"); );
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.i_alu_op & 0xf0U)))) {
        Verilated::overWidthError("i_alu_op");
    }
}
#endif  // VL_DEBUG
