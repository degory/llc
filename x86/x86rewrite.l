namespace ReWrite {
use Gen.ITree; use Gen.IString; use Gen.INumber;
class State extends System.Object {
	public int[] cost;
	public int[] rule;
	void init() { super.init(); cost = new int[18]; rule = new int[18]; }
	System.String toString() {
		System.StringBuffer b = new System.StringBuffer();
		if( cost[Selector.inst_NT] < 32767 ) { b.append("inst"); b.append('/'); b.append(cost[Selector.inst_NT]); b.append('/'); b.append(rule[Selector.inst_NT]); b.append(' '); }
		if( cost[Selector.t_NT] < 32767 ) { b.append("t"); b.append('/'); b.append(cost[Selector.t_NT]); b.append('/'); b.append(rule[Selector.t_NT]); b.append(' '); }
		if( cost[Selector.tvmi_NT] < 32767 ) { b.append("tvmi"); b.append('/'); b.append(cost[Selector.tvmi_NT]); b.append('/'); b.append(rule[Selector.tvmi_NT]); b.append(' '); }
		if( cost[Selector.tvm_NT] < 32767 ) { b.append("tvm"); b.append('/'); b.append(cost[Selector.tvm_NT]); b.append('/'); b.append(rule[Selector.tvm_NT]); b.append(' '); }
		if( cost[Selector.immed_NT] < 32767 ) { b.append("immed"); b.append('/'); b.append(cost[Selector.immed_NT]); b.append('/'); b.append(rule[Selector.immed_NT]); b.append(' '); }
		if( cost[Selector.tv_NT] < 32767 ) { b.append("tv"); b.append('/'); b.append(cost[Selector.tv_NT]); b.append('/'); b.append(rule[Selector.tv_NT]); b.append(' '); }
		if( cost[Selector.addr_NT] < 32767 ) { b.append("addr"); b.append('/'); b.append(cost[Selector.addr_NT]); b.append('/'); b.append(rule[Selector.addr_NT]); b.append(' '); }
		if( cost[Selector.mem_NT] < 32767 ) { b.append("mem"); b.append('/'); b.append(cost[Selector.mem_NT]); b.append('/'); b.append(rule[Selector.mem_NT]); b.append(' '); }
		if( cost[Selector.tvi_NT] < 32767 ) { b.append("tvi"); b.append('/'); b.append(cost[Selector.tvi_NT]); b.append('/'); b.append(rule[Selector.tvi_NT]); b.append(' '); }
		if( cost[Selector.compare_NT] < 32767 ) { b.append("compare"); b.append('/'); b.append(cost[Selector.compare_NT]); b.append('/'); b.append(rule[Selector.compare_NT]); b.append(' '); }
		if( cost[Selector.const_NT] < 32767 ) { b.append("const"); b.append('/'); b.append(cost[Selector.const_NT]); b.append('/'); b.append(rule[Selector.const_NT]); b.append(' '); }
		if( cost[Selector.global_NT] < 32767 ) { b.append("global"); b.append('/'); b.append(cost[Selector.global_NT]); b.append('/'); b.append(rule[Selector.global_NT]); b.append(' '); }
		if( cost[Selector.arg_NT] < 32767 ) { b.append("arg"); b.append('/'); b.append(cost[Selector.arg_NT]); b.append('/'); b.append(rule[Selector.arg_NT]); b.append(' '); }
		if( cost[Selector.param_NT] < 32767 ) { b.append("param"); b.append('/'); b.append(cost[Selector.param_NT]); b.append('/'); b.append(rule[Selector.param_NT]); b.append(' '); }
		if( cost[Selector.v_NT] < 32767 ) { b.append("v"); b.append('/'); b.append(cost[Selector.v_NT]); b.append('/'); b.append(rule[Selector.v_NT]); b.append(' '); }
		if( cost[Selector.base_NT] < 32767 ) { b.append("base"); b.append('/'); b.append(cost[Selector.base_NT]); b.append('/'); b.append(rule[Selector.base_NT]); b.append(' '); }
		if( cost[Selector.index_NT] < 32767 ) { b.append("index"); b.append('/'); b.append(cost[Selector.index_NT]); b.append('/'); b.append(rule[Selector.index_NT]); b.append(' '); }
	return b;
	}
}
class Selector {
public const int inst_NT = 1;
public const int t_NT = 2;
public const int tvmi_NT = 3;
public const int tvm_NT = 4;
public const int immed_NT = 5;
public const int tv_NT = 6;
public const int addr_NT = 7;
public const int mem_NT = 8;
public const int tvi_NT = 9;
public const int compare_NT = 10;
public const int const_NT = 11;
public const int global_NT = 12;
public const int arg_NT = 13;
public const int param_NT = 14;
public const int v_NT = 15;
public const int base_NT = 16;
public const int index_NT = 17;

System.String[] ntname;
	int[] nts_0;
	int[] nts_1;
	int[] nts_2;
	int[] nts_3;
	int[] nts_4;
	int[] nts_5;
	int[] nts_6;
	int[] nts_7;
	int[] nts_8;
	int[] nts_9;
	int[] nts_10;
	int[] nts_11;
	int[] nts_12;
	int[] nts_13;
	int[] nts_14;
	int[] nts_15;
	int[] nts_16;
	int[] nts_17;
	int[] nts_18;
	int[] nts_19;
	int[] nts_20;
	int[] nts_21;
	int[] nts_22;
	int[] nts_23;
	int[] nts_24;
	int[] nts_25;
	int[] nts_26;
	int[] nts_27;
	int[] nts_28;
	int[] nts_29;
	int[] nts_30;
	int[] nts_31;
	int[] nts_32;
	int[] nts_33;
	int[] nts_34;
	int[] nts_35;
	int[] nts_36;
	int[] nts_37;
	int[] nts_38;
	int[] nts_39;
	int[] nts_40;
	int[] nts_41;
	int[] nts_42;
	int[] nts_43;
	int[] nts_44;

int[][] nts;

int[] getNTS(int n) {
	return nts[n];
}

int[] decode_inst;
int[] decode_t;
int[] decode_tvmi;
int[] decode_tvm;
int[] decode_immed;
int[] decode_tv;
int[] decode_addr;
int[] decode_mem;
int[] decode_tvi;
int[] decode_compare;
int[] decode_const;
int[] decode_global;
int[] decode_arg;
int[] decode_param;
int[] decode_v;
int[] decode_base;
int[] decode_index;
int rule( State state, int goalnt) {
	if( goalnt < 1 || goalnt > 17) throw new System.Exception("rule: bad goal nonterminal: " + goalnt );
	if( state == null ) return 0;
	int nts = state.rule[goalnt];
	switch( goalnt ) {
	case inst_NT:	return decode_inst[state.rule[inst_NT]];
	case t_NT:	return decode_t[state.rule[t_NT]];
	case tvmi_NT:	return decode_tvmi[state.rule[tvmi_NT]];
	case tvm_NT:	return decode_tvm[state.rule[tvm_NT]];
	case immed_NT:	return decode_immed[state.rule[immed_NT]];
	case tv_NT:	return decode_tv[state.rule[tv_NT]];
	case addr_NT:	return decode_addr[state.rule[addr_NT]];
	case mem_NT:	return decode_mem[state.rule[mem_NT]];
	case tvi_NT:	return decode_tvi[state.rule[tvi_NT]];
	case compare_NT:	return decode_compare[state.rule[compare_NT]];
	case const_NT:	return decode_const[state.rule[const_NT]];
	case global_NT:	return decode_global[state.rule[global_NT]];
	case arg_NT:	return decode_arg[state.rule[arg_NT]];
	case param_NT:	return decode_param[state.rule[param_NT]];
	case v_NT:	return decode_v[state.rule[v_NT]];
	case base_NT:	return decode_base[state.rule[base_NT]];
	case index_NT:	return decode_index[state.rule[index_NT]];
	default:
		throw new System.Exception("rule: bad goal nonterminal " + goalnt );

		return 0;
	}
}

System.String[] nts_name;


System.String getNameNTS(int n) {
	return nts_name[n];

}

ITreeFactory[] result;
ITree getResult( int ern, ITree node, ITree[] children ) {
	return result[ern].create(node, children);
}
static int[] rewrite_goal = {
0,
0,
0,
0,
0,
0,
0,
0,
0,
8,
8,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
2,
0,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
2,
0,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
10,
10,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
6,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
7,
7,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
3,
3,
0,
0,
0,
0,
0,
6,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
5,
0,
0,
0,
0,
0,
0,
5,
0,
0,
0,
0,
0,
0,
0,
5,
0,
0,
0,
0,
0,
0,
0,
2,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
2,
0,
0,
0,
0,
0,
0,
0,
2,
0,
0,
0,
0,
0,
0,
0,
2,
0,
0,
0,
0,
0,
0,
0,
2,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
1,
1,
0,
0,
0,
0,
0,
0,
1,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
15,
15,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
2,
2,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
14,
0,
0,
0,
0,
0,
0,
0,
14,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
13,
0,
0,
0,
0,
0,
0,
0,
13,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
6,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
1,
1,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
};
public static int getReWriteGoal(int terminal) { return rewrite_goal[terminal]; }
void init() {
	nts_0 = int { inst_NT, inst_NT,  };
	nts_1 = new int[0];
	nts_2 = int { t_NT, tvmi_NT,  };
	nts_3 = int { tvmi_NT, t_NT,  };
	nts_4 = int { tvm_NT, immed_NT,  };
	nts_5 = int { immed_NT, tvm_NT,  };
	nts_6 = int { t_NT, tvm_NT,  };
	nts_7 = int { t_NT, tv_NT,  };
	nts_8 = int { t_NT,  };
	nts_9 = int { tvmi_NT,  };
	nts_10 = int { addr_NT,  };
	nts_11 = int { t_NT, addr_NT,  };
	nts_12 = int { immed_NT,  };
	nts_13 = int { tv_NT,  };
	nts_14 = int { mem_NT,  };
	nts_15 = int { tvm_NT,  };
	nts_16 = int { tv_NT, tv_NT, tv_NT,  };
	nts_17 = int { tvm_NT, tvi_NT,  };
	nts_18 = int { tvm_NT, tvm_NT, tvi_NT,  };
	nts_19 = int { tvm_NT, tvi_NT, tvm_NT,  };
	nts_20 = int { tv_NT, tv_NT, tvmi_NT,  };
	nts_21 = int { tv_NT, tvmi_NT, tv_NT,  };
	nts_22 = int { tvi_NT, tvm_NT,  };
	nts_23 = int { compare_NT,  };
	nts_24 = int { const_NT,  };
	nts_25 = int { const_NT, global_NT,  };
	nts_26 = int { global_NT, const_NT,  };
	nts_27 = int { t_NT, t_NT,  };
	nts_28 = int { inst_NT, const_NT,  };
	nts_29 = int { inst_NT, immed_NT,  };
	nts_30 = int { inst_NT, global_NT,  };
	nts_31 = int { arg_NT,  };
	nts_32 = int { t_NT, arg_NT,  };
	nts_33 = int { param_NT,  };
	nts_34 = int { t_NT, param_NT,  };
	nts_35 = int { inst_NT, tv_NT,  };
	nts_36 = int { v_NT,  };
	nts_37 = int { const_NT, tv_NT,  };
	nts_38 = int { tv_NT, const_NT,  };
	nts_39 = int { base_NT, index_NT,  };
	nts_40 = int { index_NT, base_NT,  };
	nts_41 = int { base_NT,  };
	nts_42 = int { index_NT,  };
	nts_43 = int { tv_NT, tv_NT,  };
	nts_44 = int { t_NT, immed_NT,  };
	nts = int[] {
		null,	/* 0 */

		nts_0,	/* 1 */
		nts_1,	/* 2 */
		nts_2,	/* 3 */
		nts_3,	/* 4 */
		nts_2,	/* 5 */
		nts_2,	/* 6 */
		nts_3,	/* 7 */
		nts_4,	/* 8 */
		nts_5,	/* 9 */
		nts_6,	/* 10 */
		nts_6,	/* 11 */
		nts_2,	/* 12 */
		nts_3,	/* 13 */
		nts_2,	/* 14 */
		nts_3,	/* 15 */
		nts_2,	/* 16 */
		nts_3,	/* 17 */
		nts_7,	/* 18 */
		nts_7,	/* 19 */
		nts_8,	/* 20 */
		nts_8,	/* 21 */
		nts_2,	/* 22 */
		nts_3,	/* 23 */
		nts_2,	/* 24 */
		nts_2,	/* 25 */
		nts_3,	/* 26 */
		nts_4,	/* 27 */
		nts_5,	/* 28 */
		nts_6,	/* 29 */
		nts_6,	/* 30 */
		nts_2,	/* 31 */
		nts_3,	/* 32 */
		nts_2,	/* 33 */
		nts_3,	/* 34 */
		nts_2,	/* 35 */
		nts_3,	/* 36 */
		nts_7,	/* 37 */
		nts_7,	/* 38 */
		nts_8,	/* 39 */
		nts_8,	/* 40 */
		nts_9,	/* 41 */
		nts_10,	/* 42 */
		nts_11,	/* 43 */
		nts_12,	/* 44 */
		nts_8,	/* 45 */
		nts_13,	/* 46 */
		nts_14,	/* 47 */
		nts_12,	/* 48 */
		nts_15,	/* 49 */
		nts_12,	/* 50 */
		nts_14,	/* 51 */
		nts_8,	/* 52 */
		nts_9,	/* 53 */
		nts_9,	/* 54 */
		nts_13,	/* 55 */
		nts_16,	/* 56 */
		nts_16,	/* 57 */
		nts_17,	/* 58 */
		nts_17,	/* 59 */
		nts_9,	/* 60 */
		nts_15,	/* 61 */
		nts_18,	/* 62 */
		nts_19,	/* 63 */
		nts_18,	/* 64 */
		nts_19,	/* 65 */
		nts_18,	/* 66 */
		nts_19,	/* 67 */
		nts_18,	/* 68 */
		nts_19,	/* 69 */
		nts_20,	/* 70 */
		nts_21,	/* 71 */
		nts_18,	/* 72 */
		nts_19,	/* 73 */
		nts_18,	/* 74 */
		nts_19,	/* 75 */
		nts_18,	/* 76 */
		nts_19,	/* 77 */
		nts_18,	/* 78 */
		nts_19,	/* 79 */
		nts_20,	/* 80 */
		nts_21,	/* 81 */
		nts_17,	/* 82 */
		nts_22,	/* 83 */
		nts_17,	/* 84 */
		nts_22,	/* 85 */
		nts_17,	/* 86 */
		nts_22,	/* 87 */
		nts_17,	/* 88 */
		nts_22,	/* 89 */
		nts_17,	/* 90 */
		nts_22,	/* 91 */
		nts_17,	/* 92 */
		nts_22,	/* 93 */
		nts_17,	/* 94 */
		nts_22,	/* 95 */
		nts_17,	/* 96 */
		nts_22,	/* 97 */
		nts_17,	/* 98 */
		nts_22,	/* 99 */
		nts_17,	/* 100 */
		nts_22,	/* 101 */
		nts_17,	/* 102 */
		nts_22,	/* 103 */
		nts_17,	/* 104 */
		nts_22,	/* 105 */
		nts_17,	/* 106 */
		nts_22,	/* 107 */
		nts_17,	/* 108 */
		nts_22,	/* 109 */
		nts_17,	/* 110 */
		nts_22,	/* 111 */
		nts_17,	/* 112 */
		nts_22,	/* 113 */
		nts_17,	/* 114 */
		nts_22,	/* 115 */
		nts_17,	/* 116 */
		nts_22,	/* 117 */
		nts_17,	/* 118 */
		nts_22,	/* 119 */
		nts_17,	/* 120 */
		nts_22,	/* 121 */
		nts_23,	/* 122 */
		nts_15,	/* 123 */
		nts_23,	/* 124 */
		nts_24,	/* 125 */
		nts_24,	/* 126 */
		nts_24,	/* 127 */
		nts_24,	/* 128 */
		nts_24,	/* 129 */
		nts_24,	/* 130 */
		nts_24,	/* 131 */
		nts_24,	/* 132 */
		nts_1,	/* 133 */
		nts_15,	/* 134 */
		nts_15,	/* 135 */
		nts_15,	/* 136 */
		nts_15,	/* 137 */
		nts_1,	/* 138 */
		nts_25,	/* 139 */
		nts_26,	/* 140 */
		nts_8,	/* 141 */
		nts_1,	/* 142 */
		nts_1,	/* 143 */
		nts_8,	/* 144 */
		nts_8,	/* 145 */
		nts_1,	/* 146 */
		nts_1,	/* 147 */
		nts_1,	/* 148 */
		nts_1,	/* 149 */
		nts_1,	/* 150 */
		nts_1,	/* 151 */
		nts_1,	/* 152 */
		nts_1,	/* 153 */
		nts_1,	/* 154 */
		nts_27,	/* 155 */
		nts_27,	/* 156 */
		nts_1,	/* 157 */
		nts_1,	/* 158 */
		nts_1,	/* 159 */
		nts_1,	/* 160 */
		nts_1,	/* 161 */
		nts_1,	/* 162 */
		nts_28,	/* 163 */
		nts_1,	/* 164 */
		nts_1,	/* 165 */
		nts_1,	/* 166 */
		nts_29,	/* 167 */
		nts_30,	/* 168 */
		nts_10,	/* 169 */
		nts_10,	/* 170 */
		nts_1,	/* 171 */
		nts_1,	/* 172 */
		nts_1,	/* 173 */
		nts_1,	/* 174 */
		nts_1,	/* 175 */
		nts_31,	/* 176 */
		nts_32,	/* 177 */
		nts_32,	/* 178 */
		nts_1,	/* 179 */
		nts_8,	/* 180 */
		nts_33,	/* 181 */
		nts_34,	/* 182 */
		nts_34,	/* 183 */
		nts_35,	/* 184 */
		nts_35,	/* 185 */
		nts_1,	/* 186 */
		nts_1,	/* 187 */
		nts_14,	/* 188 */
		nts_13,	/* 189 */
		nts_15,	/* 190 */
		nts_12,	/* 191 */
		nts_8,	/* 192 */
		nts_36,	/* 193 */
		nts_13,	/* 194 */
		nts_12,	/* 195 */
		nts_13,	/* 196 */
		nts_37,	/* 197 */
		nts_38,	/* 198 */
		nts_13,	/* 199 */
		nts_24,	/* 200 */
		nts_38,	/* 201 */
		nts_37,	/* 202 */
		nts_13,	/* 203 */
		nts_39,	/* 204 */
		nts_40,	/* 205 */
		nts_41,	/* 206 */
		nts_42,	/* 207 */
		nts_1,	/* 208 */
		nts_1,	/* 209 */
		nts_1,	/* 210 */
		nts_1,	/* 211 */
		nts_1,	/* 212 */
		nts_1,	/* 213 */
		nts_1,	/* 214 */
		nts_1,	/* 215 */
		nts_1,	/* 216 */
		nts_1,	/* 217 */
		nts_1,	/* 218 */
		nts_13,	/* 219 */
		nts_1,	/* 220 */
		nts_1,	/* 221 */
		nts_1,	/* 222 */
		nts_1,	/* 223 */
		nts_1,	/* 224 */
		nts_43,	/* 225 */
		nts_43,	/* 226 */
		nts_1,	/* 227 */
		nts_44,	/* 228 */
		nts_44,	/* 229 */
		nts_8,	/* 230 */
		nts_8,	/* 231 */
		nts_8,	/* 232 */
		nts_1,	/* 233 */
		nts_8,	/* 234 */
		nts_1,	/* 235 */
		nts_1,	/* 236 */
		nts_8,	/* 237 */
		nts_1,	/* 238 */
	};

	decode_inst = {
		0,
		1,
		2,
		43,
		56,
		57,
		58,
		59,
		60,
		61,
		62,
		63,
		64,
		65,
		66,
		67,
		68,
		69,
		70,
		71,
		72,
		73,
		74,
		75,
		76,
		77,
		78,
		79,
		80,
		81,
		123,
		124,
		125,
		126,
		127,
		128,
		129,
		130,
		131,
		132,
		133,
		134,
		135,
		136,
		137,
		138,
		144,
		145,
		146,
		147,
		148,
		149,
		150,
		151,
		152,
		153,
		154,
		155,
		156,
		157,
		176,
		181,
		196,
		210,
		211,
		212,
		213,
		214,
		215,
		216,
		217,
		218,
		219,
		220,
		221,
		222,
		223,
		224,
		226,
		227,
		232,
		233,
		234,
		235,
		236,
		237,
		238,
	};

	decode_t = {
		0,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		17,
		18,
		19,
		20,
		21,
		22,
		23,
		24,
		25,
		26,
		27,
		28,
		29,
		30,
		31,
		32,
		33,
		34,
		35,
		36,
		37,
		38,
		39,
		40,
		41,
		42,
		45,
		52,
		122,
		141,
		171,
		172,
		173,
		174,
		228,
		229,
		230,
		231,
	};

	decode_tvmi = {
		0,
		53,
		54,
		190,
		191,
	};

	decode_tvm = {
		0,
		188,
		189,
	};

	decode_immed = {
		0,
		44,
		48,
		50,
		142,
		143,
		164,
		165,
		166,
		167,
	};

	decode_tv = {
		0,
		46,
		49,
		55,
		184,
		185,
		192,
		193,
		225,
	};

	decode_addr = {
		0,
		204,
		205,
		206,
		207,
		208,
		209,
	};

	decode_mem = {
		0,
		47,
		51,
		169,
		170,
	};

	decode_tvi = {
		0,
		194,
		195,
	};

	decode_compare = {
		0,
		82,
		83,
		84,
		85,
		86,
		87,
		88,
		89,
		90,
		91,
		92,
		93,
		94,
		95,
		96,
		97,
		98,
		99,
		100,
		101,
		102,
		103,
		104,
		105,
		106,
		107,
		108,
		109,
		110,
		111,
		112,
		113,
		114,
		115,
		116,
		117,
		118,
		119,
		120,
		121,
	};

	decode_const = {
		0,
		139,
		140,
		159,
		160,
		161,
		162,
		163,
	};

	decode_global = {
		0,
		158,
		168,
	};

	decode_arg = {
		0,
		175,
		177,
		178,
	};

	decode_param = {
		0,
		179,
		180,
		182,
		183,
	};

	decode_v = {
		0,
		186,
		187,
	};

	decode_base = {
		0,
		197,
		198,
		199,
		200,
	};

	decode_index = {
		0,
		201,
		202,
		203,
	};

	nts_name = System.String {
		null,	/* 0 */
		"inst",	/* inst*/
		"t",	/* t*/
		"tvmi",	/* tvmi*/
		"tvm",	/* tvm*/
		"immed",	/* immed*/
		"tv",	/* tv*/
		"addr",	/* addr*/
		"mem",	/* mem*/
		"tvi",	/* tvi*/
		"compare",	/* compare*/
		"const",	/* const*/
		"global",	/* global*/
		"arg",	/* arg*/
		"param",	/* param*/
		"v",	/* v*/
		"base",	/* base*/
		"index",	/* index*/
	};
	result = ITreeFactory {
		null,

	new ITreeFactory1(),

	new ITreeFactory2(),

	new ITreeFactory3(),

	new ITreeFactory4(),

	new ITreeFactory5(),

	new ITreeFactory6(),

	new ITreeFactory7(),

	new ITreeFactory8(),

	new ITreeFactory9(),

	new ITreeFactory10(),

	new ITreeFactory11(),

	new ITreeFactory12(),

	new ITreeFactory13(),

	new ITreeFactory14(),

	new ITreeFactory15(),

	new ITreeFactory16(),

	new ITreeFactory17(),

	new ITreeFactory18(),

	new ITreeFactory19(),

	new ITreeFactory20(),

	new ITreeFactory21(),

	new ITreeFactory22(),

	new ITreeFactory23(),

	new ITreeFactory24(),

	new ITreeFactory25(),

	new ITreeFactory26(),

	new ITreeFactory27(),

	new ITreeFactory28(),

	new ITreeFactory29(),

	new ITreeFactory30(),

	new ITreeFactory31(),

	new ITreeFactory32(),

	new ITreeFactory33(),

	new ITreeFactory34(),

	new ITreeFactory35(),

	new ITreeFactory36(),

	new ITreeFactory37(),

	new ITreeFactory38(),

	new ITreeFactory39(),

	new ITreeFactory40(),

	new ITreeFactory41(),

	new ITreeFactory42(),

	new ITreeFactory43(),

	new ITreeFactory44(),

	new ITreeFactory45(),

	new ITreeFactory46(),

	new ITreeFactory47(),

	new ITreeFactory48(),

	new ITreeFactory49(),

	new ITreeFactory50(),

	new ITreeFactory51(),

	new ITreeFactory52(),

	new ITreeFactory53(),

	new ITreeFactory54(),

	new ITreeFactory55(),

	new ITreeFactory56(),

	new ITreeFactory57(),

	new ITreeFactory58(),

	new ITreeFactory59(),

	new ITreeFactory60(),

	new ITreeFactory61(),

	new ITreeFactory62(),

	new ITreeFactory63(),

	new ITreeFactory64(),

	new ITreeFactory65(),

	new ITreeFactory66(),

	new ITreeFactory67(),

	new ITreeFactory68(),

	new ITreeFactory69(),

	new ITreeFactory70(),

	new ITreeFactory71(),

	new ITreeFactory72(),

	new ITreeFactory73(),

	new ITreeFactory74(),

	new ITreeFactory75(),

	new ITreeFactory76(),

	new ITreeFactory77(),

	new ITreeFactory78(),

	new ITreeFactory79(),

	new ITreeFactory80(),

	new ITreeFactory81(),

	new ITreeFactory82(),

	new ITreeFactory83(),

	new ITreeFactory84(),

	new ITreeFactory85(),

	new ITreeFactory86(),

	new ITreeFactory87(),

	new ITreeFactory88(),

	new ITreeFactory89(),

	new ITreeFactory90(),

	new ITreeFactory91(),

	new ITreeFactory92(),

	new ITreeFactory93(),

	new ITreeFactory94(),

	new ITreeFactory95(),

	new ITreeFactory96(),

	new ITreeFactory97(),

	new ITreeFactory98(),

	new ITreeFactory99(),

	new ITreeFactory100(),

	new ITreeFactory101(),

	new ITreeFactory102(),

	new ITreeFactory103(),

	new ITreeFactory104(),

	new ITreeFactory105(),

	new ITreeFactory106(),

	new ITreeFactory107(),

	new ITreeFactory108(),

	new ITreeFactory109(),

	new ITreeFactory110(),

	new ITreeFactory111(),

	new ITreeFactory112(),

	new ITreeFactory113(),

	new ITreeFactory114(),

	new ITreeFactory115(),

	new ITreeFactory116(),

	new ITreeFactory117(),

	new ITreeFactory118(),

	new ITreeFactory119(),

	new ITreeFactory120(),

	new ITreeFactory121(),

	new ITreeFactory122(),

	new ITreeFactory123(),

	new ITreeFactory124(),

	new ITreeFactory125(),

	new ITreeFactory126(),

	new ITreeFactory127(),

	new ITreeFactory128(),

	new ITreeFactory129(),

	new ITreeFactory130(),

	new ITreeFactory131(),

	new ITreeFactory132(),

	new ITreeFactory133(),

	new ITreeFactory134(),

	new ITreeFactory135(),

	new ITreeFactory136(),

	new ITreeFactory137(),

	new ITreeFactory138(),

	new ITreeFactory139(),

	new ITreeFactory140(),

	new ITreeFactory141(),

	new ITreeFactory142(),

	new ITreeFactory143(),

	new ITreeFactory144(),

	new ITreeFactory145(),

	new ITreeFactory146(),

	new ITreeFactory147(),

	new ITreeFactory148(),

	new ITreeFactory149(),

	new ITreeFactory150(),

	new ITreeFactory151(),

	new ITreeFactory152(),

	new ITreeFactory153(),

	new ITreeFactory154(),

	new ITreeFactory155(),

	new ITreeFactory156(),

	new ITreeFactory157(),

	new ITreeFactory158(),

	new ITreeFactory159(),

	new ITreeFactory160(),

	new ITreeFactory161(),

	new ITreeFactory162(),

	new ITreeFactory163(),

	new ITreeFactory164(),

	new ITreeFactory165(),

	new ITreeFactory166(),

	new ITreeFactory167(),

	new ITreeFactory168(),

	new ITreeFactory169(),

	new ITreeFactory170(),

	new ITreeFactory171(),

	new ITreeFactory172(),

	new ITreeFactory173(),

	new ITreeFactory174(),

	new ITreeFactory175(),

	new ITreeFactory176(),

	new ITreeFactory177(),

	new ITreeFactory178(),

	new ITreeFactory179(),

	new ITreeFactory180(),

	new ITreeFactory181(),

	new ITreeFactory182(),

	new ITreeFactory183(),

	new ITreeFactory184(),

	new ITreeFactory185(),

	new ITreeFactory186(),

	new ITreeFactory187(),

	new ITreeFactory188(),

	new ITreeFactory189(),

	new ITreeFactory190(),

	new ITreeFactory191(),

	new ITreeFactory192(),

	new ITreeFactory193(),

	new ITreeFactory194(),

	new ITreeFactory195(),

	new ITreeFactory196(),

	new ITreeFactory197(),

	new ITreeFactory198(),

	new ITreeFactory199(),

	new ITreeFactory200(),

	new ITreeFactory201(),

	new ITreeFactory202(),

	new ITreeFactory203(),

	new ITreeFactory204(),

	new ITreeFactory205(),

	new ITreeFactory206(),

	new ITreeFactory207(),

	new ITreeFactory208(),

	new ITreeFactory209(),

	new ITreeFactory210(),

	new ITreeFactory211(),

	new ITreeFactory212(),

	new ITreeFactory213(),

	new ITreeFactory214(),

	new ITreeFactory215(),

	new ITreeFactory216(),

	new ITreeFactory217(),

	new ITreeFactory218(),

	new ITreeFactory219(),

	new ITreeFactory220(),

	new ITreeFactory221(),

	new ITreeFactory222(),

	new ITreeFactory223(),

	new ITreeFactory224(),

	new ITreeFactory225(),

	new ITreeFactory226(),

	new ITreeFactory227(),

	new ITreeFactory228(),

	new ITreeFactory229(),

	new ITreeFactory230(),

	new ITreeFactory231(),

	new ITreeFactory232(),

	new ITreeFactory233(),

	new ITreeFactory234(),

	new ITreeFactory235(),

	new ITreeFactory236(),

	new ITreeFactory237(),

	new ITreeFactory238(),
	};
}
void closure_t(ITree a, int c) {
	State p = a.getReWriteState();
	// match t -> tv 192->tv ?
	if(c + 0 < p.cost[tv_NT]) {
		p.cost[tv_NT] = c + 0;
		p.rule[tv_NT] = 6;
		closure_tv(a, c + 0);
	}
}

void closure_tvmi(ITree a, int c) {
	State p = a.getReWriteState();
	// match tvmi -> t 41->t ?
	if(c + 10 < p.cost[t_NT]) {
		p.cost[t_NT] = c + 10;
		p.rule[t_NT] = 39;
		closure_t(a, c + 10);
	}
}

void closure_tvm(ITree a, int c) {
	State p = a.getReWriteState();
	// match tvm -> tvmi 190->tvmi ?
	if(c + 0 < p.cost[tvmi_NT]) {
		p.cost[tvmi_NT] = c + 0;
		p.rule[tvmi_NT] = 3;
		closure_tvmi(a, c + 0);
	}
}

void closure_immed(ITree a, int c) {
	State p = a.getReWriteState();
	// match immed -> tvi 195->tvi ?
	if(c + 0 < p.cost[tvi_NT]) {
		p.cost[tvi_NT] = c + 0;
		p.rule[tvi_NT] = 2;
	}
	// match immed -> tvmi 191->tvmi ?
	if(c + 0 < p.cost[tvmi_NT]) {
		p.cost[tvmi_NT] = c + 0;
		p.rule[tvmi_NT] = 4;
		closure_tvmi(a, c + 0);
	}
}

void closure_tv(ITree a, int c) {
	State p = a.getReWriteState();
	// match tv -> index 203->index ?
	if(c + 1 < p.cost[index_NT]) {
		p.cost[index_NT] = c + 1;
		p.rule[index_NT] = 3;
		closure_index(a, c + 1);
	}
	// match tv -> base 199->base ?
	if(c + 0 < p.cost[base_NT]) {
		p.cost[base_NT] = c + 0;
		p.rule[base_NT] = 3;
		closure_base(a, c + 0);
	}
	// match tv -> inst 196->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 62;
	}
	// match tv -> tvi 194->tvi ?
	if(c + 0 < p.cost[tvi_NT]) {
		p.cost[tvi_NT] = c + 0;
		p.rule[tvi_NT] = 1;
	}
	// match tv -> tvm 189->tvm ?
	if(c + 0 < p.cost[tvm_NT]) {
		p.cost[tvm_NT] = c + 0;
		p.rule[tvm_NT] = 2;
		closure_tvm(a, c + 0);
	}
}

void closure_addr(ITree a, int c) {
	State p = a.getReWriteState();
	// match addr -> t 42->t ?
	if(c + 15 < p.cost[t_NT]) {
		p.cost[t_NT] = c + 15;
		p.rule[t_NT] = 40;
		closure_t(a, c + 15);
	}
}

void closure_mem(ITree a, int c) {
	State p = a.getReWriteState();
	// match mem -> tvm 188->tvm ?
	if(c + 0 < p.cost[tvm_NT]) {
		p.cost[tvm_NT] = c + 0;
		p.rule[tvm_NT] = 1;
		closure_tvm(a, c + 0);
	}
}

void closure_compare(ITree a, int c) {
	State p = a.getReWriteState();
	// match compare -> t 122->t ?
	if(c + 20 < p.cost[t_NT]) {
		p.cost[t_NT] = c + 20;
		p.rule[t_NT] = 43;
		closure_t(a, c + 20);
	}
}

void closure_const(ITree a, int c) {
	State p = a.getReWriteState();
	// match const -> base 200->base ?
	if(c + 0 < p.cost[base_NT]) {
		p.cost[base_NT] = c + 0;
		p.rule[base_NT] = 4;
		closure_base(a, c + 0);
	}
}

void closure_arg(ITree a, int c) {
	State p = a.getReWriteState();
	// match arg -> inst 176->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 60;
	}
}

void closure_param(ITree a, int c) {
	State p = a.getReWriteState();
	// match param -> inst 181->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 61;
	}
}

void closure_v(ITree a, int c) {
	State p = a.getReWriteState();
	// match v -> tv 193->tv ?
	if(c + 0 < p.cost[tv_NT]) {
		p.cost[tv_NT] = c + 0;
		p.rule[tv_NT] = 7;
		closure_tv(a, c + 0);
	}
}

void closure_base(ITree a, int c) {
	State p = a.getReWriteState();
	// match base -> addr 206->addr ?
	if(c + 0 < p.cost[addr_NT]) {
		p.cost[addr_NT] = c + 0;
		p.rule[addr_NT] = 3;
		closure_addr(a, c + 0);
	}
}

void closure_index(ITree a, int c) {
	State p = a.getReWriteState();
	// match index -> addr 207->addr ?
	if(c + 0 < p.cost[addr_NT]) {
		p.cost[addr_NT] = c + 0;
		p.rule[addr_NT] = 4;
		closure_addr(a, c + 0);
	}
}

void label0(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 0: /* ERROR_0 */
		break;
		case 9: /* INDIRECT_1 */
		label(a.getLeft());
		/* [INDIRECT_1 addr] -> mem 170 */		c = a.getLeft().getReWriteState().cost[addr_NT] + 
0;
		// match [INDIRECT_1 addr] -> mem 170->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 4;
			closure_mem(a, c + 0);
		}
		break;
		case 10: /* INDIRECT_4 */
		label(a.getLeft());
		/* [INDIRECT_4 addr] -> mem 169 */		c = a.getLeft().getReWriteState().cost[addr_NT] + 
0;
		// match [INDIRECT_4 addr] -> mem 169->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 3;
			closure_mem(a, c + 0);
		}
		break;
		case 11: /* INDIRECT_8 */
		break;
		case 17: /* LEA_1 */
		break;
		case 18: /* LEA_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LEA_4 t addr] -> inst 43 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[addr_NT] + 
15;
		// match [LEA_4 t addr] -> inst 43->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 3;
		}
		break;
		case 19: /* LEA_8 */
		break;
		case 25: /* ADD_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD_1 t tvmi] -> t 22 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [ADD_1 t tvmi] -> t 22->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 20;
			closure_t(a, c + 0);
		}
		/* [ADD_1 tvmi t] -> t 23 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [ADD_1 tvmi t] -> t 23->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 21;
			closure_t(a, c + 0);
		}
		break;
		case 26: /* ADD_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD_4 t tvmi] -> t 3 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [ADD_4 t tvmi] -> t 3->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 1;
			closure_t(a, c + 0);
		}
		/* [ADD_4 tvmi t] -> t 4 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [ADD_4 tvmi t] -> t 4->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 2;
			closure_t(a, c + 0);
		}
		/* [ADD_4 const global] -> const 139 */
		c = a.getLeft().getReWriteState().cost[const_NT] + 
a.getRight().getReWriteState().cost[global_NT] + 
0;
		// match [ADD_4 const global] -> const 139->const ?
		if(c + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = c + 0;
			p.rule[const_NT] = 1;
			closure_const(a, c + 0);
		}
		/* [ADD_4 global const] -> const 140 */
		c = a.getLeft().getReWriteState().cost[global_NT] + 
a.getRight().getReWriteState().cost[const_NT] + 
0;
		// match [ADD_4 global const] -> const 140->const ?
		if(c + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = c + 0;
			p.rule[const_NT] = 2;
			closure_const(a, c + 0);
		}
		/* [ADD_4 const tv] -> base 197 */
		c = a.getLeft().getReWriteState().cost[const_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
0;
		// match [ADD_4 const tv] -> base 197->base ?
		if(c + 0 < p.cost[base_NT]) {
			p.cost[base_NT] = c + 0;
			p.rule[base_NT] = 1;
			closure_base(a, c + 0);
		}
		/* [ADD_4 tv const] -> base 198 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[const_NT] + 
0;
		// match [ADD_4 tv const] -> base 198->base ?
		if(c + 0 < p.cost[base_NT]) {
			p.cost[base_NT] = c + 0;
			p.rule[base_NT] = 2;
			closure_base(a, c + 0);
		}
		/* [ADD_4 base index] -> addr 204 */
		c = a.getLeft().getReWriteState().cost[base_NT] + 
a.getRight().getReWriteState().cost[index_NT] + 
0;
		// match [ADD_4 base index] -> addr 204->addr ?
		if(c + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = c + 0;
			p.rule[addr_NT] = 1;
			closure_addr(a, c + 0);
		}
		/* [ADD_4 index base] -> addr 205 */
		c = a.getLeft().getReWriteState().cost[index_NT] + 
a.getRight().getReWriteState().cost[base_NT] + 
0;
		// match [ADD_4 index base] -> addr 205->addr ?
		if(c + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = c + 0;
			p.rule[addr_NT] = 2;
			closure_addr(a, c + 0);
		}
		break;
		case 27: /* ADD_8 */
		break;
		case 29: /* ADD2_1 */
		break;
		case 30: /* ADD2_4 */
		break;
		case 31: /* ADD2_8 */
		break;
		case 33: /* SUB_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SUB_1 t tvmi] -> t 24 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [SUB_1 t tvmi] -> t 24->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 22;
			closure_t(a, c + 0);
		}
		break;
		case 34: /* SUB_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SUB_4 t tvmi] -> t 5 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [SUB_4 t tvmi] -> t 5->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 3;
			closure_t(a, c + 0);
		}
		break;
		case 35: /* SUB_8 */
		break;
		case 37: /* SUB2_1 */
		break;
		case 38: /* SUB2_4 */
		break;
		case 39: /* SUB2_8 */
		break;
		case 41: /* SUBR_1 */
		break;
		case 42: /* SUBR_4 */
		break;
		case 43: /* SUBR_8 */
		break;
		case 45: /* SUBR2_1 */
		break;
		case 46: /* SUBR2_4 */
		break;
		case 47: /* SUBR2_8 */
		break;
		case 49: /* MUL_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [MUL_1 t tvmi] -> t 25 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [MUL_1 t tvmi] -> t 25->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 23;
			closure_t(a, c + 0);
		}
		/* [MUL_1 tvmi t] -> t 26 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [MUL_1 tvmi t] -> t 26->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 24;
			closure_t(a, c + 0);
		}
		/* [MUL_1 tvm immed] -> t 27 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
10;
		// match [MUL_1 tvm immed] -> t 27->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 25;
			closure_t(a, c + 0);
		}
		/* [MUL_1 immed tvm] -> t 28 */
		c = a.getLeft().getReWriteState().cost[immed_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MUL_1 immed tvm] -> t 28->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 26;
			closure_t(a, c + 0);
		}
		break;
	default:
		if( a.getOperator() > 49) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label1(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 50: /* MUL_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [MUL_4 t tvmi] -> t 6 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [MUL_4 t tvmi] -> t 6->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 4;
			closure_t(a, c + 0);
		}
		/* [MUL_4 tvmi t] -> t 7 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [MUL_4 tvmi t] -> t 7->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 5;
			closure_t(a, c + 0);
		}
		/* [MUL_4 tvm immed] -> t 8 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
10;
		// match [MUL_4 tvm immed] -> t 8->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 6;
			closure_t(a, c + 0);
		}
		/* [MUL_4 immed tvm] -> t 9 */
		c = a.getLeft().getReWriteState().cost[immed_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MUL_4 immed tvm] -> t 9->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 7;
			closure_t(a, c + 0);
		}
		/* [MUL_4 tv const] -> index 201 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[const_NT] + 
( a.scaleRight(1,32768) );
		// match [MUL_4 tv const] -> index 201->index ?
		if(c + 0 < p.cost[index_NT]) {
			p.cost[index_NT] = c + 0;
			p.rule[index_NT] = 1;
			closure_index(a, c + 0);
		}
		/* [MUL_4 const tv] -> index 202 */
		c = a.getLeft().getReWriteState().cost[const_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
( a.scaleLeft(1,32768) );
		// match [MUL_4 const tv] -> index 202->index ?
		if(c + 0 < p.cost[index_NT]) {
			p.cost[index_NT] = c + 0;
			p.rule[index_NT] = 2;
			closure_index(a, c + 0);
		}
		break;
		case 51: /* MUL_8 */
		break;
		case 53: /* MUL2_1 */
		break;
		case 54: /* MUL2_4 */
		break;
		case 55: /* MUL2_8 */
		break;
		case 57: /* DIV_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [DIV_1 t tvm] -> t 29 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [DIV_1 t tvm] -> t 29->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 27;
			closure_t(a, c + 0);
		}
		break;
		case 58: /* DIV_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [DIV_4 t tvm] -> t 10 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [DIV_4 t tvm] -> t 10->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 8;
			closure_t(a, c + 0);
		}
		break;
		case 59: /* DIV_8 */
		break;
		case 61: /* DIV2_1 */
		break;
		case 62: /* DIV2_4 */
		break;
		case 63: /* DIV2_8 */
		break;
		case 65: /* DIVR_1 */
		break;
		case 66: /* DIVR_4 */
		break;
		case 67: /* DIVR_8 */
		break;
		case 69: /* DIVR2_1 */
		break;
		case 70: /* DIVR2_4 */
		break;
		case 71: /* DIVR2_8 */
		break;
		case 73: /* MOD_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [MOD_1 t tvm] -> t 30 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MOD_1 t tvm] -> t 30->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 28;
			closure_t(a, c + 0);
		}
		break;
		case 74: /* MOD_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [MOD_4 t tvm] -> t 11 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MOD_4 t tvm] -> t 11->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 9;
			closure_t(a, c + 0);
		}
		break;
		case 75: /* MOD_8 */
		break;
		case 77: /* MOD2_1 */
		break;
		case 78: /* MOD2_4 */
		break;
		case 79: /* MOD2_8 */
		break;
		case 81: /* SHL_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHL_1 t tv] -> t 37 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHL_1 t tv] -> t 37->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 35;
			closure_t(a, c + 0);
		}
		break;
		case 82: /* SHL_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHL_4 t tv] -> t 18 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHL_4 t tv] -> t 18->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 16;
			closure_t(a, c + 0);
		}
		break;
		case 83: /* SHL_8 */
		break;
		case 85: /* SHL2_1 */
		break;
		case 86: /* SHL2_4 */
		break;
		case 87: /* SHL2_8 */
		break;
		case 89: /* SHAR_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHAR_1 t tv] -> t 38 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHAR_1 t tv] -> t 38->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 36;
			closure_t(a, c + 0);
		}
		break;
		case 90: /* SHAR_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHAR_4 t tv] -> t 19 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHAR_4 t tv] -> t 19->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 17;
			closure_t(a, c + 0);
		}
		break;
		case 91: /* SHAR_8 */
		break;
		case 93: /* SHAR2_1 */
		break;
		case 94: /* SHAR2_4 */
		break;
		case 95: /* SHAR2_8 */
		break;
		case 97: /* EQ_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [EQ_1 tvm tvi] -> compare 102 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [EQ_1 tvm tvi] -> compare 102->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 21;
			closure_compare(a, c + 0);
		}
		/* [EQ_1 tvi tvm] -> compare 103 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [EQ_1 tvi tvm] -> compare 103->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 22;
			closure_compare(a, c + 0);
		}
		break;
		case 98: /* EQ_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [EQ_4 tvm tvi] -> compare 82 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [EQ_4 tvm tvi] -> compare 82->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 1;
			closure_compare(a, c + 0);
		}
		/* [EQ_4 tvi tvm] -> compare 83 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [EQ_4 tvi tvm] -> compare 83->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 2;
			closure_compare(a, c + 0);
		}
		break;
		case 99: /* EQ_8 */
		break;
	default:
		if( a.getOperator() > 99) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label2(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 101: /* EQ2_1 */
		break;
		case 102: /* EQ2_4 */
		break;
		case 103: /* EQ2_8 */
		break;
		case 105: /* NE_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [NE_1 tvm tvi] -> compare 104 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [NE_1 tvm tvi] -> compare 104->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 23;
			closure_compare(a, c + 0);
		}
		/* [NE_1 tvi tvm] -> compare 105 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [NE_1 tvi tvm] -> compare 105->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 24;
			closure_compare(a, c + 0);
		}
		break;
		case 106: /* NE_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [NE_4 tvm tvi] -> compare 84 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [NE_4 tvm tvi] -> compare 84->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 3;
			closure_compare(a, c + 0);
		}
		/* [NE_4 tvi tvm] -> compare 85 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [NE_4 tvi tvm] -> compare 85->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 4;
			closure_compare(a, c + 0);
		}
		break;
		case 107: /* NE_8 */
		break;
		case 109: /* NE2_1 */
		break;
		case 110: /* NE2_4 */
		break;
		case 111: /* NE2_8 */
		break;
		case 113: /* GT_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [GT_1 tvm tvi] -> compare 106 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GT_1 tvm tvi] -> compare 106->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 25;
			closure_compare(a, c + 0);
		}
		/* [GT_1 tvi tvm] -> compare 107 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GT_1 tvi tvm] -> compare 107->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 26;
			closure_compare(a, c + 0);
		}
		break;
		case 114: /* GT_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GT_4 tvm tvi] -> compare 86 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GT_4 tvm tvi] -> compare 86->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 5;
			closure_compare(a, c + 0);
		}
		/* [GT_4 tvi tvm] -> compare 87 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GT_4 tvi tvm] -> compare 87->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 6;
			closure_compare(a, c + 0);
		}
		break;
		case 115: /* GT_8 */
		break;
		case 117: /* GT2_1 */
		break;
		case 118: /* GT2_4 */
		break;
		case 119: /* GT2_8 */
		break;
		case 121: /* LT_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [LT_1 tvm tvi] -> compare 108 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LT_1 tvm tvi] -> compare 108->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 27;
			closure_compare(a, c + 0);
		}
		/* [LT_1 tvi tvm] -> compare 109 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LT_1 tvi tvm] -> compare 109->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 28;
			closure_compare(a, c + 0);
		}
		break;
		case 122: /* LT_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LT_4 tvm tvi] -> compare 88 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LT_4 tvm tvi] -> compare 88->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 7;
			closure_compare(a, c + 0);
		}
		/* [LT_4 tvi tvm] -> compare 89 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LT_4 tvi tvm] -> compare 89->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 8;
			closure_compare(a, c + 0);
		}
		break;
		case 123: /* LT_8 */
		break;
		case 125: /* LT2_1 */
		break;
		case 126: /* LT2_4 */
		break;
		case 127: /* LT2_8 */
		break;
		case 129: /* GE_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [GE_1 tvm tvi] -> compare 110 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GE_1 tvm tvi] -> compare 110->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 29;
			closure_compare(a, c + 0);
		}
		/* [GE_1 tvi tvm] -> compare 111 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GE_1 tvi tvm] -> compare 111->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 30;
			closure_compare(a, c + 0);
		}
		break;
		case 130: /* GE_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GE_4 tvm tvi] -> compare 90 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GE_4 tvm tvi] -> compare 90->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 9;
			closure_compare(a, c + 0);
		}
		/* [GE_4 tvi tvm] -> compare 91 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GE_4 tvi tvm] -> compare 91->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 10;
			closure_compare(a, c + 0);
		}
		break;
		case 131: /* GE_8 */
		break;
		case 133: /* GE2_1 */
		break;
		case 134: /* GE2_4 */
		break;
		case 135: /* GE2_8 */
		break;
		case 137: /* LE_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [LE_1 tvm tvi] -> compare 112 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LE_1 tvm tvi] -> compare 112->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 31;
			closure_compare(a, c + 0);
		}
		/* [LE_1 tvi tvm] -> compare 113 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LE_1 tvi tvm] -> compare 113->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 32;
			closure_compare(a, c + 0);
		}
		break;
		case 138: /* LE_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LE_4 tvm tvi] -> compare 92 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LE_4 tvm tvi] -> compare 92->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 11;
			closure_compare(a, c + 0);
		}
		/* [LE_4 tvi tvm] -> compare 93 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LE_4 tvi tvm] -> compare 93->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 12;
			closure_compare(a, c + 0);
		}
		break;
		case 139: /* LE_8 */
		break;
		case 141: /* LE2_1 */
		break;
		case 142: /* LE2_4 */
		break;
		case 143: /* LE2_8 */
		break;
		case 145: /* GTU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [GTU_1 tvm tvi] -> compare 114 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GTU_1 tvm tvi] -> compare 114->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 33;
			closure_compare(a, c + 0);
		}
		/* [GTU_1 tvi tvm] -> compare 115 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GTU_1 tvi tvm] -> compare 115->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 34;
			closure_compare(a, c + 0);
		}
		break;
		case 146: /* GTU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GTU_4 tvm tvi] -> compare 94 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GTU_4 tvm tvi] -> compare 94->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 13;
			closure_compare(a, c + 0);
		}
		/* [GTU_4 tvi tvm] -> compare 95 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GTU_4 tvi tvm] -> compare 95->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 14;
			closure_compare(a, c + 0);
		}
		break;
		case 147: /* GTU_8 */
		break;
		case 149: /* GTU2_1 */
		break;
	default:
		if( a.getOperator() > 149) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label3(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 150: /* GTU2_4 */
		break;
		case 151: /* GTU2_8 */
		break;
		case 153: /* LTU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [LTU_1 tvm tvi] -> compare 116 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LTU_1 tvm tvi] -> compare 116->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 35;
			closure_compare(a, c + 0);
		}
		/* [LTU_1 tvi tvm] -> compare 117 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LTU_1 tvi tvm] -> compare 117->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 36;
			closure_compare(a, c + 0);
		}
		break;
		case 154: /* LTU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LTU_4 tvm tvi] -> compare 96 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LTU_4 tvm tvi] -> compare 96->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 15;
			closure_compare(a, c + 0);
		}
		/* [LTU_4 tvi tvm] -> compare 97 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LTU_4 tvi tvm] -> compare 97->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 16;
			closure_compare(a, c + 0);
		}
		break;
		case 155: /* LTU_8 */
		break;
		case 157: /* LTU2_1 */
		break;
		case 158: /* LTU2_4 */
		break;
		case 159: /* LTU2_8 */
		break;
		case 161: /* GEU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [GEU_1 tvm tvi] -> compare 118 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GEU_1 tvm tvi] -> compare 118->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 37;
			closure_compare(a, c + 0);
		}
		/* [GEU_1 tvi tvm] -> compare 119 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GEU_1 tvi tvm] -> compare 119->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 38;
			closure_compare(a, c + 0);
		}
		break;
		case 162: /* GEU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GEU_4 tvm tvi] -> compare 98 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GEU_4 tvm tvi] -> compare 98->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 17;
			closure_compare(a, c + 0);
		}
		/* [GEU_4 tvi tvm] -> compare 99 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GEU_4 tvi tvm] -> compare 99->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 18;
			closure_compare(a, c + 0);
		}
		break;
		case 163: /* GEU_8 */
		break;
		case 165: /* GEU2_1 */
		break;
		case 166: /* GEU2_4 */
		break;
		case 167: /* GEU2_8 */
		break;
		case 169: /* LEU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [LEU_1 tvm tvi] -> compare 120 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LEU_1 tvm tvi] -> compare 120->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 39;
			closure_compare(a, c + 0);
		}
		/* [LEU_1 tvi tvm] -> compare 121 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LEU_1 tvi tvm] -> compare 121->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 40;
			closure_compare(a, c + 0);
		}
		break;
		case 170: /* LEU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LEU_4 tvm tvi] -> compare 100 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LEU_4 tvm tvi] -> compare 100->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 19;
			closure_compare(a, c + 0);
		}
		/* [LEU_4 tvi tvm] -> compare 101 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LEU_4 tvi tvm] -> compare 101->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 20;
			closure_compare(a, c + 0);
		}
		break;
		case 171: /* LEU_8 */
		break;
		case 173: /* LEU2_1 */
		break;
		case 174: /* LEU2_4 */
		break;
		case 175: /* LEU2_8 */
		break;
		case 177: /* AND_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [AND_1 t tvmi] -> t 31 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [AND_1 t tvmi] -> t 31->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 29;
			closure_t(a, c + 0);
		}
		/* [AND_1 tvmi t] -> t 32 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [AND_1 tvmi t] -> t 32->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 30;
			closure_t(a, c + 0);
		}
		break;
		case 178: /* AND_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [AND_4 t tvmi] -> t 12 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [AND_4 t tvmi] -> t 12->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 10;
			closure_t(a, c + 0);
		}
		/* [AND_4 tvmi t] -> t 13 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [AND_4 tvmi t] -> t 13->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 11;
			closure_t(a, c + 0);
		}
		break;
		case 179: /* AND_8 */
		break;
		case 181: /* AND2_1 */
		break;
		case 182: /* AND2_4 */
		break;
		case 183: /* AND2_8 */
		break;
		case 185: /* OR_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [OR_1 t tvmi] -> t 33 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [OR_1 t tvmi] -> t 33->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 31;
			closure_t(a, c + 0);
		}
		/* [OR_1 tvmi t] -> t 34 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [OR_1 tvmi t] -> t 34->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 32;
			closure_t(a, c + 0);
		}
		break;
		case 186: /* OR_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [OR_4 t tvmi] -> t 14 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [OR_4 t tvmi] -> t 14->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 12;
			closure_t(a, c + 0);
		}
		/* [OR_4 tvmi t] -> t 15 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [OR_4 tvmi t] -> t 15->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 13;
			closure_t(a, c + 0);
		}
		break;
		case 187: /* OR_8 */
		break;
		case 189: /* OR2_1 */
		break;
		case 190: /* OR2_4 */
		break;
		case 191: /* OR2_8 */
		break;
		case 193: /* XOR_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [XOR_1 t tvmi] -> t 35 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [XOR_1 t tvmi] -> t 35->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 33;
			closure_t(a, c + 0);
		}
		/* [XOR_1 tvmi t] -> t 36 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [XOR_1 tvmi t] -> t 36->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 34;
			closure_t(a, c + 0);
		}
		break;
		case 194: /* XOR_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [XOR_4 t tvmi] -> t 16 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [XOR_4 t tvmi] -> t 16->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 14;
			closure_t(a, c + 0);
		}
		/* [XOR_4 tvmi t] -> t 17 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [XOR_4 tvmi t] -> t 17->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 15;
			closure_t(a, c + 0);
		}
		break;
		case 195: /* XOR_8 */
		break;
		case 197: /* XOR2_1 */
		break;
		case 198: /* XOR2_4 */
		break;
		case 199: /* XOR2_8 */
		break;
	default:
		if( a.getOperator() > 199) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label4(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 201: /* NOT_1 */
		label(a.getLeft());
		/* [NOT_1 t] -> t 40 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NOT_1 t] -> t 40->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 38;
			closure_t(a, c + 0);
		}
		break;
		case 202: /* NOT_4 */
		label(a.getLeft());
		/* [NOT_4 t] -> t 21 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NOT_4 t] -> t 21->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 19;
			closure_t(a, c + 0);
		}
		break;
		case 203: /* NOT_8 */
		break;
		case 205: /* NOT2_1 */
		break;
		case 206: /* NOT2_4 */
		break;
		case 207: /* NOT2_8 */
		break;
		case 209: /* NEG_1 */
		label(a.getLeft());
		/* [NEG_1 t] -> t 39 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NEG_1 t] -> t 39->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 37;
			closure_t(a, c + 0);
		}
		break;
		case 210: /* NEG_4 */
		label(a.getLeft());
		/* [NEG_4 t] -> t 20 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NEG_4 t] -> t 20->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 18;
			closure_t(a, c + 0);
		}
		break;
		case 211: /* NEG_8 */
		break;
		case 213: /* NEG2_1 */
		break;
		case 214: /* NEG2_4 */
		break;
		case 215: /* NEG2_8 */
		break;
		case 217: /* ELIGIBLE_CSE_1 */
		break;
		case 218: /* ELIGIBLE_CSE_4 */
		break;
		case 219: /* ELIGIBLE_CSE_8 */
		break;
		case 225: /* CSE_1 */
		break;
		case 226: /* CSE_4 */
		break;
		case 227: /* CSE_8 */
		break;
		case 232: /* NOP_0 */
		break;
		case 240: /* COMMENT_0 */
		//COMMENT_0 -> inst 2->COMMENT_0 ?
		/* COMMENT_0 -> inst 2 arity 0 */
		// match COMMENT_0 -> inst 2->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 2;
		}
		//COMMENT_0 -> arg 175->COMMENT_0 ?
		/* COMMENT_0 -> arg 175 arity 0 */
		// match COMMENT_0 -> arg 175->arg ?
		if(10 + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = 10 + 0;
			p.rule[arg_NT] = 1;
			closure_arg(a, 10 + 0);
		}
		//COMMENT_0 -> param 179->COMMENT_0 ?
		/* COMMENT_0 -> param 179 arity 0 */
		// match COMMENT_0 -> param 179->param ?
		if(10 + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = 10 + 0;
			p.rule[param_NT] = 1;
			closure_param(a, 10 + 0);
		}
		break;
		case 248: /* DUMMY_0 */
		break;
	default:
		if( a.getOperator() > 248) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label5(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 256: /* OBJ_EQ_0 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [OBJ_EQ_0 [PAIR_4 tv tv] tv] -> inst 56 arity 2 */
			a.getLeft().getOperator() == 578 /* BB PAIR_4*/
		) {
			c = a.getLeft().getLeft().getReWriteState().cost[tv_NT] + 
a.getLeft().getRight().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
20;
			// match [OBJ_EQ_0 [PAIR_4 tv tv] tv] -> inst 56->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 4;
			}
}
		break;
		case 260: /* OBJ_EQ2_0 */
		break;
		case 264: /* OBJ_NE_0 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [OBJ_NE_0 [PAIR_4 tv tv] tv] -> inst 57 arity 2 */
			a.getLeft().getOperator() == 578 /* BB PAIR_4*/
		) {
			c = a.getLeft().getLeft().getReWriteState().cost[tv_NT] + 
a.getLeft().getRight().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
20;
			// match [OBJ_NE_0 [PAIR_4 tv tv] tv] -> inst 57->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 5;
			}
}
		break;
		case 268: /* OBJ_NE2_0 */
		break;
		case 272: /* BOUNDS_L_0 */
		//BOUNDS_L_0 -> inst 227->BOUNDS_L_0 ?
		/* BOUNDS_L_0 -> inst 227 arity 0 */
		// match BOUNDS_L_0 -> inst 227->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 79;
		}
		break;
		case 280: /* BOUNDS_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [BOUNDS_0 tv tv] -> tv 225 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [BOUNDS_0 tv tv] -> tv 225->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 8;
			closure_tv(a, c + 0);
		}
		break;
		case 288: /* BOUNDS_R_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [BOUNDS_R_0 tv tv] -> inst 226 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [BOUNDS_R_0 tv tv] -> inst 226->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 78;
		}
		break;
		case 297: /* LOCAL_1 */
		//LOCAL_1 -> addr 209->LOCAL_1 ?
		/* LOCAL_1 -> addr 209 arity 0 */
		// match LOCAL_1 -> addr 209->addr ?
		if(0 + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = 0 + 0;
			p.rule[addr_NT] = 6;
			closure_addr(a, 0 + 0);
		}
		break;
		case 298: /* LOCAL_4 */
		//LOCAL_4 -> addr 208->LOCAL_4 ?
		/* LOCAL_4 -> addr 208 arity 0 */
		// match LOCAL_4 -> addr 208->addr ?
		if(0 + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = 0 + 0;
			p.rule[addr_NT] = 5;
			closure_addr(a, 0 + 0);
		}
		break;
		case 299: /* LOCAL_8 */
		break;
	default:
		if( a.getOperator() > 299) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label6(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 305: /* RLOCAL_1 */
		break;
		case 306: /* RLOCAL_4 */
		break;
		case 307: /* RLOCAL_8 */
		break;
		case 313: /* INSTANCE_1 */
		break;
		case 314: /* INSTANCE_4 */
		break;
		case 315: /* INSTANCE_8 */
		break;
		case 320: /* EXTERN_0 */
		//EXTERN_0 -> inst 214->EXTERN_0 ?
		/* EXTERN_0 -> inst 214 arity 0 */
		// match EXTERN_0 -> inst 214->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 67;
		}
		break;
		case 329: /* GLOBAL_1 */
		break;
		case 330: /* GLOBAL_4 */
		//GLOBAL_4 -> global 158->GLOBAL_4 ?
		/* GLOBAL_4 -> global 158 arity 0 */
		// match GLOBAL_4 -> global 158->global ?
		if(0 + 0 < p.cost[global_NT]) {
			p.cost[global_NT] = 0 + 0;
			p.rule[global_NT] = 1;
		}
		//GLOBAL_4 -> const 159->GLOBAL_4 ?
		/* GLOBAL_4 -> const 159 arity 0 */
		// match GLOBAL_4 -> const 159->const ?
		if(0 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 0 + 0;
			p.rule[const_NT] = 3;
			closure_const(a, 0 + 0);
		}
		//GLOBAL_4 -> immed 164->GLOBAL_4 ?
		/* GLOBAL_4 -> immed 164 arity 0 */
		// match GLOBAL_4 -> immed 164->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 6;
			closure_immed(a, 0 + 0);
		}
		break;
		case 331: /* GLOBAL_8 */
		break;
		case 336: /* LABEL_0 */
		//LABEL_0 -> const 161->LABEL_0 ?
		/* LABEL_0 -> const 161 arity 0 */
		// match LABEL_0 -> const 161->const ?
		if(50 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 50 + 0;
			p.rule[const_NT] = 5;
			closure_const(a, 50 + 0);
		}
		//LABEL_0 -> inst 212->LABEL_0 ?
		/* LABEL_0 -> inst 212 arity 0 */
		// match LABEL_0 -> inst 212->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 65;
		}
		break;
		case 344: /* DLABEL_0 */
		//DLABEL_0 -> const 162->DLABEL_0 ?
		/* DLABEL_0 -> const 162 arity 0 */
		// match DLABEL_0 -> const 162->const ?
		if(50 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 50 + 0;
			p.rule[const_NT] = 6;
			closure_const(a, 50 + 0);
		}
		//DLABEL_0 -> inst 213->DLABEL_0 ?
		/* DLABEL_0 -> inst 213 arity 0 */
		// match DLABEL_0 -> inst 213->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 66;
		}
		break;
	default:
		if( a.getOperator() > 344) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label7(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 354: /* CAST_FROM1_4 */
		label(a.getLeft());
		/* [CAST_FROM1_4 immed] -> immed 48 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM1_4 immed] -> immed 48->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 2;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM1_4 tvm] -> tv 49 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [CAST_FROM1_4 tvm] -> tv 49->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 2;
			closure_tv(a, c + 0);
		}
		break;
		case 355: /* CAST_FROM1_8 */
		break;
		case 358: /* CAST_FROM11_4 */
		break;
		case 359: /* CAST_FROM11_8 */
		break;
		case 361: /* CAST_FROM4_1 */
		label(a.getLeft());
		/* [CAST_FROM4_1 immed] -> immed 50 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM4_1 immed] -> immed 50->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 3;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM4_1 mem] -> mem 51 */		c = a.getLeft().getReWriteState().cost[mem_NT] + 
0;
		// match [CAST_FROM4_1 mem] -> mem 51->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 2;
			closure_mem(a, c + 0);
		}
		/* [CAST_FROM4_1 t] -> t 52 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [CAST_FROM4_1 t] -> t 52->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 42;
			closure_t(a, c + 0);
		}
		break;
		case 362: /* CAST_FROM4_4 */
		label(a.getLeft());
		/* [CAST_FROM4_4 immed] -> immed 44 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM4_4 immed] -> immed 44->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 1;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM4_4 t] -> t 45 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [CAST_FROM4_4 t] -> t 45->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 41;
			closure_t(a, c + 0);
		}
		/* [CAST_FROM4_4 tv] -> tv 46 */		c = a.getLeft().getReWriteState().cost[tv_NT] + 
1;
		// match [CAST_FROM4_4 tv] -> tv 46->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 1;
			closure_tv(a, c + 0);
		}
		/* [CAST_FROM4_4 mem] -> mem 47 */		c = a.getLeft().getReWriteState().cost[mem_NT] + 
0;
		// match [CAST_FROM4_4 mem] -> mem 47->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 1;
			closure_mem(a, c + 0);
		}
		break;
		case 363: /* CAST_FROM4_8 */
		break;
		case 365: /* CAST_FROM41_1 */
		break;
		case 366: /* CAST_FROM41_4 */
		break;
		case 367: /* CAST_FROM41_8 */
		break;
		case 369: /* CAST_FROM8_1 */
		break;
		case 370: /* CAST_FROM8_4 */
		break;
		case 373: /* CAST_FROM81_1 */
		break;
		case 374: /* CAST_FROM81_4 */
		break;
		case 377: /* TREAT_AS_1 */
		label(a.getLeft());
		/* [TREAT_AS_1 tvmi] -> tvmi 54 */		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
0;
		// match [TREAT_AS_1 tvmi] -> tvmi 54->tvmi ?
		if(c + 0 < p.cost[tvmi_NT]) {
			p.cost[tvmi_NT] = c + 0;
			p.rule[tvmi_NT] = 2;
			closure_tvmi(a, c + 0);
		}
		break;
		case 378: /* TREAT_AS_4 */
		label(a.getLeft());
		/* [TREAT_AS_4 tvmi] -> tvmi 53 */		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
0;
		// match [TREAT_AS_4 tvmi] -> tvmi 53->tvmi ?
		if(c + 0 < p.cost[tvmi_NT]) {
			p.cost[tvmi_NT] = c + 0;
			p.rule[tvmi_NT] = 1;
			closure_tvmi(a, c + 0);
		}
		break;
		case 379: /* TREAT_AS_8 */
		break;
		case 381: /* TREAT_AS1_1 */
		break;
		case 382: /* TREAT_AS1_4 */
		break;
		case 383: /* TREAT_AS1_8 */
		break;
		case 384: /* CAST_CHECK_0 */
		label(a.getLeft());
		/* [CAST_CHECK_0 tv] -> tv 55 */		c = a.getLeft().getReWriteState().cost[tv_NT] + 
10;
		// match [CAST_CHECK_0 tv] -> tv 55->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 3;
			closure_tv(a, c + 0);
		}
		break;
		case 388: /* CAST_CHECK1_0 */
		break;
		case 392: /* THIS_0 */
		break;
	default:
		if( a.getOperator() > 392) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label8(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 400: /* FRAME_0 */
		break;
		case 409: /* CONST_1 */
		//CONST_1 -> immed 166->CONST_1 ?
		/* CONST_1 -> immed 166 arity 0 */
		// match CONST_1 -> immed 166->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 8;
			closure_immed(a, 0 + 0);
		}
		break;
		case 410: /* CONST_4 */
		//CONST_4 -> const 160->CONST_4 ?
		/* CONST_4 -> const 160 arity 0 */
		// match CONST_4 -> const 160->const ?
		if(0 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 0 + 0;
			p.rule[const_NT] = 4;
			closure_const(a, 0 + 0);
		}
		//CONST_4 -> immed 165->CONST_4 ?
		/* CONST_4 -> immed 165 arity 0 */
		// match CONST_4 -> immed 165->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 7;
			closure_immed(a, 0 + 0);
		}
		break;
		case 411: /* CONST_8 */
		break;
		case 416: /* CONST_STR_0 */
		//CONST_STR_0 -> immed 142->CONST_STR_0 ?
		/* CONST_STR_0 -> immed 142 arity 0 */
		// match CONST_STR_0 -> immed 142->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 4;
			closure_immed(a, 0 + 0);
		}
		break;
		case 424: /* CONST_CSTR_0 */
		//CONST_CSTR_0 -> immed 143->CONST_CSTR_0 ?
		/* CONST_CSTR_0 -> immed 143 arity 0 */
		// match CONST_CSTR_0 -> immed 143->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 5;
			closure_immed(a, 0 + 0);
		}
		break;
		case 432: /* BOX_0 */
		label(a.getLeft());
		/* [BOX_0 t] -> t 141 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [BOX_0 t] -> t 141->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 44;
			closure_t(a, c + 0);
		}
		break;
		case 440: /* BOOL_OR_0 */
		break;
		case 442: /* BOOL_OR_4 */
		break;
		case 443: /* BOOL_OR_8 */
		break;
		case 449: /* BOOL_AND_1 */
		break;
	default:
		if( a.getOperator() > 449) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label9(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 450: /* BOOL_AND_4 */
		break;
		case 451: /* BOOL_AND_8 */
		break;
		case 457: /* BOOL_NOT_1 */
		break;
		case 458: /* BOOL_NOT_4 */
		break;
		case 459: /* BOOL_NOT_8 */
		break;
		case 464: /* STORE_THIS_0 */
		break;
		case 472: /* SAVE_THIS_0 */
		break;
		case 480: /* RESTORE_THIS_0 */
		break;
		case 488: /* CALL_0 */
		//CALL_0 -> inst 236->CALL_0 ?
		/* CALL_0 -> inst 236 arity 0 */
		// match CALL_0 -> inst 236->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 84;
		}
		break;
		case 496: /* STATIC_CALL_0 */
		label(a.getLeft());
		/* [STATIC_CALL_0 t] -> inst 232 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [STATIC_CALL_0 t] -> inst 232->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 80;
		}
		break;
	default:
		if( a.getOperator() > 496) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label10(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 504: /* DYNAMIC_CALL_0 */
		label(a.getLeft());
		/* [DYNAMIC_CALL_0 t] -> inst 234 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [DYNAMIC_CALL_0 t] -> inst 234->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 82;
		}
		break;
		case 512: /* STATIC_DYNAMIC_CALL_0 */
		break;
		case 520: /* STATIC_CALL_DISCARD_0 */
		//STATIC_CALL_DISCARD_0 -> inst 233->STATIC_CALL_DISCARD_0 ?
		/* STATIC_CALL_DISCARD_0 -> inst 233 arity 0 */
		// match STATIC_CALL_DISCARD_0 -> inst 233->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 81;
		}
		break;
		case 528: /* DYNAMIC_CALL_DISCARD_0 */
		//DYNAMIC_CALL_DISCARD_0 -> inst 235->DYNAMIC_CALL_DISCARD_0 ?
		/* DYNAMIC_CALL_DISCARD_0 -> inst 235 arity 0 */
		// match DYNAMIC_CALL_DISCARD_0 -> inst 235->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 83;
		}
		break;
		case 536: /* STATIC_DYNAMIC_CALL_DISCARD_0 */
		break;
		case 544: /* NEW_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [NEW_0 t immed] -> t 228 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
10;
		// match [NEW_0 t immed] -> t 228->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 49;
			closure_t(a, c + 0);
		}
		break;
	default:
		if( a.getOperator() > 544) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label11(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 552: /* NEW_FINALIZE_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [NEW_FINALIZE_0 t immed] -> t 229 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
10;
		// match [NEW_FINALIZE_0 t immed] -> t 229->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 50;
			closure_t(a, c + 0);
		}
		break;
		case 560: /* NEW_ARRAY_0 */
		label(a.getLeft());
		/* [NEW_ARRAY_0 t] -> t 231 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NEW_ARRAY_0 t] -> t 231->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 52;
			closure_t(a, c + 0);
		}
		break;
		case 568: /* NEW_OBJ_ARRAY_0 */
		label(a.getLeft());
		/* [NEW_OBJ_ARRAY_0 t] -> t 230 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NEW_OBJ_ARRAY_0 t] -> t 230->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 51;
			closure_t(a, c + 0);
		}
		break;
		case 577: /* PAIR_1 */
		break;
		case 578: /* PAIR_4 */
		label(a.getLeft());
		label(a.getRight());
		break;
		case 579: /* PAIR_8 */
		break;
		case 585: /* PUSH_1 */
		break;
		case 586: /* PUSH_4 */
		label(a.getLeft());
		/* [PUSH_4 tvmi] -> inst 60 */		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
10;
		// match [PUSH_4 tvmi] -> inst 60->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 8;
		}
		break;
		case 587: /* PUSH_8 */
		break;
		case 593: /* POP_1 */
		break;
		case 594: /* POP_4 */
		label(a.getLeft());
		/* [POP_4 tvm] -> inst 61 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [POP_4 tvm] -> inst 61->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 9;
		}
		break;
		case 595: /* POP_8 */
		break;
	default:
		if( a.getOperator() > 595) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label12(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 600: /* RET_0 */
		//RET_0 -> inst 221->RET_0 ?
		/* RET_0 -> inst 221 arity 0 */
		c = ( a.const0(32767,10) );		// match RET_0 -> inst 221->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 74;
		}
		//RET_0 -> inst 222->RET_0 ?
		/* RET_0 -> inst 222 arity 0 */
		c = ( a.const0(10,32767) );		// match RET_0 -> inst 222->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 75;
		}
		break;
		case 609: /* STORE_1 */
		break;
		case 610: /* STORE_4 */
		break;
		case 611: /* STORE_8 */
		break;
		case 617: /* THROW_1 */
		break;
		case 618: /* THROW_4 */
		label(a.getLeft());
		/* [THROW_4 t] -> inst 237 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [THROW_4 t] -> inst 237->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 85;
		}
		break;
		case 619: /* THROW_8 */
		break;
		case 624: /* TRY_0 */
		//TRY_0 -> inst 152->TRY_0 ?
		/* TRY_0 -> inst 152 arity 0 */
		// match TRY_0 -> inst 152->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 54;
		}
		break;
		case 632: /* START_CATCH_0 */
		//START_CATCH_0 -> inst 220->START_CATCH_0 ?
		/* START_CATCH_0 -> inst 220 arity 0 */
		// match START_CATCH_0 -> inst 220->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 73;
		}
		break;
		case 640: /* CATCH_0 */
		break;
		case 648: /* SUSPEND_CATCH_0 */
		//SUSPEND_CATCH_0 -> inst 157->SUSPEND_CATCH_0 ?
		/* SUSPEND_CATCH_0 -> inst 157 arity 0 */
		// match SUSPEND_CATCH_0 -> inst 157->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 59;
		}
		break;
	default:
		if( a.getOperator() > 648) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label13(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 656: /* END_FINALLY_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [END_FINALLY_0 t t] -> inst 156 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
0;
		// match [END_FINALLY_0 t t] -> inst 156->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 58;
		}
		break;
		case 664: /* END_CATCH_0 */
		//END_CATCH_0 -> inst 154->END_CATCH_0 ?
		/* END_CATCH_0 -> inst 154 arity 0 */
		// match END_CATCH_0 -> inst 154->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 56;
		}
		break;
		case 672: /* END_TRY_0 */
		//END_TRY_0 -> inst 153->END_TRY_0 ?
		/* END_TRY_0 -> inst 153 arity 0 */
		// match END_TRY_0 -> inst 153->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 55;
		}
		break;
		case 680: /* COND_RETHROW_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [COND_RETHROW_0 t t] -> inst 155 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
0;
		// match [COND_RETHROW_0 t t] -> inst 155->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 57;
		}
		break;
		case 688: /* COND_RETURN_0 */
		break;
		case 697: /* THROW_RETURN_1 */
		break;
		case 698: /* THROW_RETURN_4 */
		label(a.getLeft());
		/* [THROW_RETURN_4 tv] -> inst 219 */		c = a.getLeft().getReWriteState().cost[tv_NT] + 
10;
		// match [THROW_RETURN_4 tv] -> inst 219->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 72;
		}
		break;
		case 699: /* THROW_RETURN_8 */
		break;
	default:
		if( a.getOperator() > 699) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label14(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 704: /* RETURN_RETHROW_0 */
		break;
		case 712: /* ADJUST_0 */
		break;
		case 720: /* PUSH_EBP_0 */
		break;
		case 728: /* SAVE_ALL_0 */
		//SAVE_ALL_0 -> inst 215->SAVE_ALL_0 ?
		/* SAVE_ALL_0 -> inst 215 arity 0 */
		// match SAVE_ALL_0 -> inst 215->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 68;
		}
		break;
		case 736: /* RESTORE_ALL_0 */
		//RESTORE_ALL_0 -> inst 216->RESTORE_ALL_0 ?
		/* RESTORE_ALL_0 -> inst 216 arity 0 */
		// match RESTORE_ALL_0 -> inst 216->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 69;
		}
		break;
		case 744: /* JUMP_0 */
		//JUMP_0 -> inst 138->JUMP_0 ?
		/* JUMP_0 -> inst 138 arity 0 */
		// match JUMP_0 -> inst 138->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 45;
		}
		break;
	default:
		if( a.getOperator() > 744) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label15(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 752: /* DUMMY_JUMP_0 */
		//DUMMY_JUMP_0 -> inst 238->DUMMY_JUMP_0 ?
		/* DUMMY_JUMP_0 -> inst 238 arity 0 */
		// match DUMMY_JUMP_0 -> inst 238->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 86;
		}
		break;
		case 761: /* CMP_1 */
		break;
		case 762: /* CMP_4 */
		break;
		case 763: /* CMP_8 */
		break;
		case 765: /* CMP2_1 */
		break;
		case 766: /* CMP2_4 */
		break;
		case 767: /* CMP2_8 */
		break;
		case 769: /* DECBNN_1 */
		break;
		case 770: /* DECBNN_4 */
		label(a.getLeft());
		/* [DECBNN_4 tvm] -> inst 123 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
20;
		// match [DECBNN_4 tvm] -> inst 123->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 30;
		}
		break;
		case 771: /* DECBNN_8 */
		break;
		case 773: /* DECBNN1_1 */
		break;
		case 774: /* DECBNN1_4 */
		break;
		case 775: /* DECBNN1_8 */
		break;
		case 776: /* BRANCH_0 */
		label(a.getLeft());
		/* [BRANCH_0 compare] -> inst 124 */		c = a.getLeft().getReWriteState().cost[compare_NT] + 
10;
		// match [BRANCH_0 compare] -> inst 124->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 31;
		}
		break;
		case 780: /* BRANCH1_0 */
		break;
		case 785: /* BRANCHZ_1 */
		label(a.getLeft());
		/* [BRANCHZ_1 const] -> inst 129 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHZ_1 const] -> inst 129->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 36;
		}
		/* [BRANCHZ_1 const] -> inst 130 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHZ_1 const] -> inst 130->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 37;
		}
		/* [BRANCHZ_1 tvm] -> inst 136 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHZ_1 tvm] -> inst 136->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 43;
		}
		break;
		case 786: /* BRANCHZ_4 */
		label(a.getLeft());
		/* [BRANCHZ_4 const] -> inst 125 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHZ_4 const] -> inst 125->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 32;
		}
		/* [BRANCHZ_4 const] -> inst 126 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHZ_4 const] -> inst 126->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 33;
		}
		/* [BRANCHZ_4 tvm] -> inst 134 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHZ_4 tvm] -> inst 134->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 41;
		}
		break;
		case 787: /* BRANCHZ_8 */
		break;
		case 789: /* BRANCHZ1_1 */
		break;
		case 790: /* BRANCHZ1_4 */
		break;
		case 791: /* BRANCHZ1_8 */
		break;
		case 793: /* BRANCHNZ_1 */
		label(a.getLeft());
		/* [BRANCHNZ_1 const] -> inst 131 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHNZ_1 const] -> inst 131->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 38;
		}
		/* [BRANCHNZ_1 const] -> inst 132 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHNZ_1 const] -> inst 132->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 39;
		}
		/* [BRANCHNZ_1 tvm] -> inst 137 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHNZ_1 tvm] -> inst 137->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 44;
		}
		break;
		case 794: /* BRANCHNZ_4 */
		label(a.getLeft());
		/* [BRANCHNZ_4 const] -> inst 127 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHNZ_4 const] -> inst 127->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 34;
		}
		/* [BRANCHNZ_4 const] -> inst 128 */		c = a.getLeft().getReWriteState().cost[const_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHNZ_4 const] -> inst 128->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 35;
		}
		/* [BRANCHNZ_4 tvm] -> inst 135 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHNZ_4 tvm] -> inst 135->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 42;
		}
		break;
		case 795: /* BRANCHNZ_8 */
		break;
		case 797: /* BRANCHNZ1_1 */
		break;
		case 798: /* BRANCHNZ1_4 */
		break;
		case 799: /* BRANCHNZ1_8 */
		break;
	default:
		if( a.getOperator() > 799) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label16(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 800: /* JE_0 */
		break;
		case 808: /* JNE_0 */
		break;
		case 816: /* JG_0 */
		break;
		case 824: /* JL_0 */
		break;
		case 832: /* JGE_0 */
		break;
		case 840: /* JLE_0 */
		break;
		case 848: /* JGU_0 */
		break;
	default:
		if( a.getOperator() > 848) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label17(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 856: /* JLU_0 */
		break;
		case 864: /* JGEU_0 */
		break;
		case 872: /* JLEU_0 */
		break;
		case 881: /* SETE_1 */
		break;
		case 889: /* SETNE_1 */
		break;
		case 897: /* SETG_1 */
		break;
	default:
		if( a.getOperator() > 897) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label18(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 905: /* SETL_1 */
		break;
		case 913: /* SETGE_1 */
		break;
		case 921: /* SETLE_1 */
		break;
		case 929: /* SETGU_1 */
		break;
		case 937: /* SETLU_1 */
		break;
		case 945: /* SETGEU_1 */
		break;
	default:
		if( a.getOperator() > 945) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label19(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 953: /* SETLEU_1 */
		break;
		case 960: /* RESERVE_0 */
		//RESERVE_0 -> inst 217->RESERVE_0 ?
		/* RESERVE_0 -> inst 217 arity 0 */
		// match RESERVE_0 -> inst 217->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 70;
		}
		break;
		case 968: /* RELEASE_0 */
		//RELEASE_0 -> inst 218->RELEASE_0 ?
		/* RELEASE_0 -> inst 218 arity 0 */
		// match RELEASE_0 -> inst 218->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 71;
		}
		break;
		case 976: /* ENTER_0 */
		//ENTER_0 -> inst 210->ENTER_0 ?
		/* ENTER_0 -> inst 210 arity 0 */
		// match ENTER_0 -> inst 210->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 63;
		}
		break;
		case 984: /* LEAVE_0 */
		//LEAVE_0 -> inst 211->LEAVE_0 ?
		/* LEAVE_0 -> inst 211 arity 0 */
		// match LEAVE_0 -> inst 211->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 64;
		}
		break;
		case 993: /* RESULT_1 */
		break;
		case 994: /* RESULT_4 */
		label(a.getLeft());
		/* [RESULT_4 t] -> inst 144 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [RESULT_4 t] -> inst 144->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 46;
		}
		/* [RESULT_4 t] -> param 180 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
40;
		// match [RESULT_4 t] -> param 180->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 2;
			closure_param(a, c + 0);
		}
		break;
		case 995: /* RESULT_8 */
		break;
	default:
		if( a.getOperator() > 995) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label20(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1000: /* RESULT_F_0 */
		label(a.getLeft());
		/* [RESULT_F_0 t] -> inst 145 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [RESULT_F_0 t] -> inst 145->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 47;
		}
		break;
		case 1008: /* ENTER_LOOP_0 */
		//ENTER_LOOP_0 -> inst 223->ENTER_LOOP_0 ?
		/* ENTER_LOOP_0 -> inst 223 arity 0 */
		// match ENTER_LOOP_0 -> inst 223->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 76;
		}
		break;
		case 1016: /* LEAVE_LOOP_0 */
		//LEAVE_LOOP_0 -> inst 224->LEAVE_LOOP_0 ?
		/* LEAVE_LOOP_0 -> inst 224 arity 0 */
		// match LEAVE_LOOP_0 -> inst 224->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 77;
		}
		break;
		case 1024: /* LINE_0 */
		//LINE_0 -> inst 133->LINE_0 ?
		/* LINE_0 -> inst 133 arity 0 */
		// match LINE_0 -> inst 133->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 40;
		}
		break;
		case 1033: /* REG_VAR_1 */
		//REG_VAR_1 -> v 187->REG_VAR_1 ?
		/* REG_VAR_1 -> v 187 arity 0 */
		// match REG_VAR_1 -> v 187->v ?
		if(0 + 0 < p.cost[v_NT]) {
			p.cost[v_NT] = 0 + 0;
			p.rule[v_NT] = 2;
			closure_v(a, 0 + 0);
		}
		break;
		case 1034: /* REG_VAR_4 */
		//REG_VAR_4 -> v 186->REG_VAR_4 ?
		/* REG_VAR_4 -> v 186 arity 0 */
		// match REG_VAR_4 -> v 186->v ?
		if(0 + 0 < p.cost[v_NT]) {
			p.cost[v_NT] = 0 + 0;
			p.rule[v_NT] = 1;
			closure_v(a, 0 + 0);
		}
		break;
		case 1035: /* REG_VAR_8 */
		break;
		case 1041: /* REGISTER_1 */
		//REGISTER_1 -> t 174->REGISTER_1 ?
		/* REGISTER_1 -> t 174 arity 0 */
		// match REGISTER_1 -> t 174->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 48;
			closure_t(a, 0 + 0);
		}
		break;
		case 1042: /* REGISTER_4 */
		//REGISTER_4 -> t 173->REGISTER_4 ?
		/* REGISTER_4 -> t 173 arity 0 */
		// match REGISTER_4 -> t 173->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 47;
			closure_t(a, 0 + 0);
		}
		break;
		case 1043: /* REGISTER_8 */
		break;
		case 1049: /* TEMP_1 */
		//TEMP_1 -> t 172->TEMP_1 ?
		/* TEMP_1 -> t 172 arity 0 */
		// match TEMP_1 -> t 172->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 46;
			closure_t(a, 0 + 0);
		}
		break;
	default:
		if( a.getOperator() > 1049) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label21(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1050: /* TEMP_4 */
		//TEMP_4 -> t 171->TEMP_4 ?
		/* TEMP_4 -> t 171 arity 0 */
		// match TEMP_4 -> t 171->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 45;
			closure_t(a, 0 + 0);
		}
		break;
		case 1051: /* TEMP_8 */
		break;
		case 1057: /* MEMORY_1 */
		break;
		case 1058: /* MEMORY_4 */
		break;
		case 1059: /* MEMORY_8 */
		break;
		case 1065: /* PARAM0_1 */
		break;
		case 1066: /* PARAM0_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM0_4 t param] -> param 182 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM0_4 t param] -> param 182->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 3;
			closure_param(a, c + 0);
		}
		break;
		case 1067: /* PARAM0_8 */
		break;
		case 1073: /* PARAM1_1 */
		break;
		case 1074: /* PARAM1_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM1_4 t param] -> param 183 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM1_4 t param] -> param 183->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 4;
			closure_param(a, c + 0);
		}
		break;
		case 1075: /* PARAM1_8 */
		break;
		case 1081: /* PARAM2_1 */
		break;
		case 1082: /* PARAM2_4 */
		break;
		case 1083: /* PARAM2_8 */
		break;
		case 1089: /* PARAM3_1 */
		break;
		case 1090: /* PARAM3_4 */
		break;
		case 1091: /* PARAM3_8 */
		break;
		case 1097: /* PARAM4_1 */
		break;
		case 1098: /* PARAM4_4 */
		break;
		case 1099: /* PARAM4_8 */
		break;
	default:
		if( a.getOperator() > 1099) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label22(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1105: /* PARAM5_1 */
		break;
		case 1106: /* PARAM5_4 */
		break;
		case 1107: /* PARAM5_8 */
		break;
		case 1113: /* ARG0_1 */
		break;
		case 1114: /* ARG0_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG0_4 t arg] -> arg 177 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG0_4 t arg] -> arg 177->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 2;
			closure_arg(a, c + 0);
		}
		break;
		case 1115: /* ARG0_8 */
		break;
		case 1121: /* ARG1_1 */
		break;
		case 1122: /* ARG1_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG1_4 t arg] -> arg 178 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG1_4 t arg] -> arg 178->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 3;
			closure_arg(a, c + 0);
		}
		break;
		case 1123: /* ARG1_8 */
		break;
		case 1129: /* ARG2_1 */
		break;
		case 1130: /* ARG2_4 */
		break;
		case 1131: /* ARG2_8 */
		break;
		case 1137: /* ARG3_1 */
		break;
		case 1138: /* ARG3_4 */
		break;
		case 1139: /* ARG3_8 */
		break;
		case 1145: /* ARG4_1 */
		break;
		case 1146: /* ARG4_4 */
		break;
		case 1147: /* ARG4_8 */
		break;
	default:
		if( a.getOperator() > 1147) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label23(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1153: /* ARG5_1 */
		break;
		case 1154: /* ARG5_4 */
		break;
		case 1155: /* ARG5_8 */
		break;
		case 1160: /* INIT_REG_VAR_0 */
		break;
		case 1168: /* SAVE_REG_VAR_0 */
		break;
		case 1176: /* RESTORE_REG_VAR_0 */
		break;
		case 1185: /* SEQ_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SEQ_1 inst tv] -> tv 185 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
0;
		// match [SEQ_1 inst tv] -> tv 185->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 5;
			closure_tv(a, c + 0);
		}
		break;
		case 1186: /* SEQ_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SEQ_4 inst const] -> const 163 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[const_NT] + 
0;
		// match [SEQ_4 inst const] -> const 163->const ?
		if(c + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = c + 0;
			p.rule[const_NT] = 7;
			closure_const(a, c + 0);
		}
		/* [SEQ_4 inst immed] -> immed 167 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
0;
		// match [SEQ_4 inst immed] -> immed 167->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 9;
			closure_immed(a, c + 0);
		}
		/* [SEQ_4 inst global] -> global 168 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[global_NT] + 
0;
		// match [SEQ_4 inst global] -> global 168->global ?
		if(c + 0 < p.cost[global_NT]) {
			p.cost[global_NT] = c + 0;
			p.rule[global_NT] = 2;
		}
		/* [SEQ_4 inst tv] -> tv 184 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
0;
		// match [SEQ_4 inst tv] -> tv 184->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 4;
			closure_tv(a, c + 0);
		}
		break;
		case 1187: /* SEQ_8 */
		break;
		case 1192: /* LIST_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [LIST_0 inst inst] -> inst 1 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[inst_NT] + 
0;
		// match [LIST_0 inst inst] -> inst 1->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 1;
		}
		break;
	default:
		if( a.getOperator() > 1192) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label24(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1201: /* COPY_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [COPY_1 tvm tvi] -> inst 59 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
10;
		// match [COPY_1 tvm tvi] -> inst 59->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 7;
		}
		if(/* [COPY_1 tvm [ADD_1 tvm tvi]] -> inst 72 arity 2 */
			a.getRight().getOperator() == 25 /* BB ADD_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_1 tvm [ADD_1 tvm tvi]] -> inst 72->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 20;
			}
}
		if(/* [COPY_1 tvm [ADD_1 tvi tvm]] -> inst 73 arity 2 */
			a.getRight().getOperator() == 25 /* BB ADD_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_1 tvm [ADD_1 tvi tvm]] -> inst 73->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 21;
			}
}
		if(/* [COPY_1 tvm [AND_1 tvm tvi]] -> inst 74 arity 2 */
			a.getRight().getOperator() == 177 /* BB AND_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_1 tvm [AND_1 tvm tvi]] -> inst 74->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 22;
			}
}
		if(/* [COPY_1 tvm [AND_1 tvi tvm]] -> inst 75 arity 2 */
			a.getRight().getOperator() == 177 /* BB AND_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_1 tvm [AND_1 tvi tvm]] -> inst 75->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 23;
			}
}
		if(/* [COPY_1 tvm [OR_1 tvm tvi]] -> inst 76 arity 2 */
			a.getRight().getOperator() == 185 /* BB OR_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_1 tvm [OR_1 tvm tvi]] -> inst 76->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 24;
			}
}
		if(/* [COPY_1 tvm [OR_1 tvi tvm]] -> inst 77 arity 2 */
			a.getRight().getOperator() == 185 /* BB OR_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_1 tvm [OR_1 tvi tvm]] -> inst 77->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 25;
			}
}
		if(/* [COPY_1 tvm [SUB_1 tvm tvi]] -> inst 78 arity 2 */
			a.getRight().getOperator() == 33 /* BB SUB_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_1 tvm [SUB_1 tvm tvi]] -> inst 78->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 26;
			}
}
		if(/* [COPY_1 tvm [SUB_1 tvi tvm]] -> inst 79 arity 2 */
			a.getRight().getOperator() == 33 /* BB SUB_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_1 tvm [SUB_1 tvi tvm]] -> inst 79->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 27;
			}
}
		if(/* [COPY_1 tv [MUL_1 tv tvmi]] -> inst 80 arity 2 */
			a.getRight().getOperator() == 49 /* BB MUL_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getRight().getReWriteState().cost[tvmi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_1 tv [MUL_1 tv tvmi]] -> inst 80->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 28;
			}
}
		if(/* [COPY_1 tv [MUL_1 tvmi tv]] -> inst 81 arity 2 */
			a.getRight().getOperator() == 49 /* BB MUL_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getRight().getReWriteState().cost[tv_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_1 tv [MUL_1 tvmi tv]] -> inst 81->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 29;
			}
}
		break;
		case 1202: /* COPY_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [COPY_4 tvm tvi] -> inst 58 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
10;
		// match [COPY_4 tvm tvi] -> inst 58->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 6;
		}
		if(/* [COPY_4 tvm [ADD_4 tvm tvi]] -> inst 62 arity 2 */
			a.getRight().getOperator() == 26 /* BB ADD_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_4 tvm [ADD_4 tvm tvi]] -> inst 62->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 10;
			}
}
		if(/* [COPY_4 tvm [ADD_4 tvi tvm]] -> inst 63 arity 2 */
			a.getRight().getOperator() == 26 /* BB ADD_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_4 tvm [ADD_4 tvi tvm]] -> inst 63->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 11;
			}
}
		if(/* [COPY_4 tvm [AND_4 tvm tvi]] -> inst 64 arity 2 */
			a.getRight().getOperator() == 178 /* BB AND_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_4 tvm [AND_4 tvm tvi]] -> inst 64->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 12;
			}
}
		if(/* [COPY_4 tvm [AND_4 tvi tvm]] -> inst 65 arity 2 */
			a.getRight().getOperator() == 178 /* BB AND_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_4 tvm [AND_4 tvi tvm]] -> inst 65->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 13;
			}
}
		if(/* [COPY_4 tvm [OR_4 tvm tvi]] -> inst 66 arity 2 */
			a.getRight().getOperator() == 186 /* BB OR_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_4 tvm [OR_4 tvm tvi]] -> inst 66->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 14;
			}
}
		if(/* [COPY_4 tvm [OR_4 tvi tvm]] -> inst 67 arity 2 */
			a.getRight().getOperator() == 186 /* BB OR_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_4 tvm [OR_4 tvi tvm]] -> inst 67->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 15;
			}
}
		if(/* [COPY_4 tvm [SUB_4 tvm tvi]] -> inst 68 arity 2 */
			a.getRight().getOperator() == 34 /* BB SUB_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_4 tvm [SUB_4 tvm tvi]] -> inst 68->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 16;
			}
}
		if(/* [COPY_4 tvm [SUB_4 tvi tvm]] -> inst 69 arity 2 */
			a.getRight().getOperator() == 34 /* BB SUB_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_4 tvm [SUB_4 tvi tvm]] -> inst 69->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 17;
			}
}
		if(/* [COPY_4 tv [MUL_4 tv tvmi]] -> inst 70 arity 2 */
			a.getRight().getOperator() == 50 /* BB MUL_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getRight().getReWriteState().cost[tvmi_NT] + 
( a.mem2mem(1,32768) );
			// match [COPY_4 tv [MUL_4 tv tvmi]] -> inst 70->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 18;
			}
}
		if(/* [COPY_4 tv [MUL_4 tvmi tv]] -> inst 71 arity 2 */
			a.getRight().getOperator() == 50 /* BB MUL_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getRight().getReWriteState().cost[tv_NT] + 
( a.mem2memR(1,32768) );
			// match [COPY_4 tv [MUL_4 tvmi tv]] -> inst 71->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 19;
			}
}
		break;
		case 1203: /* COPY_8 */
		break;
		case 1208: /* STATIC_0 */
		//STATIC_0 -> inst 148->STATIC_0 ?
		/* STATIC_0 -> inst 148 arity 0 */
		// match STATIC_0 -> inst 148->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 50;
		}
		break;
		case 1216: /* TEXT_0 */
		//TEXT_0 -> inst 149->TEXT_0 ?
		/* TEXT_0 -> inst 149 arity 0 */
		// match TEXT_0 -> inst 149->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 51;
		}
		break;
		case 1224: /* DATA_0 */
		//DATA_0 -> inst 150->DATA_0 ?
		/* DATA_0 -> inst 150 arity 0 */
		// match DATA_0 -> inst 150->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 52;
		}
		break;
		case 1232: /* RODATA_0 */
		//RODATA_0 -> inst 151->RODATA_0 ?
		/* RODATA_0 -> inst 151 arity 0 */
		// match RODATA_0 -> inst 151->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 53;
		}
		break;
		case 1240: /* UNWIND_0 */
		break;
		case 1248: /* PUSHSEG_0 */
		//PUSHSEG_0 -> inst 146->PUSHSEG_0 ?
		/* PUSHSEG_0 -> inst 146 arity 0 */
		// match PUSHSEG_0 -> inst 146->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 48;
		}
		break;
	default:
		if( a.getOperator() > 1248) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label25(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1256: /* POPSEG_0 */
		//POPSEG_0 -> inst 147->POPSEG_0 ?
		/* POPSEG_0 -> inst 147 arity 0 */
		// match POPSEG_0 -> inst 147->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 49;
		}
		break;
		case 1264: /* RELOC_0 */
		break;
		case 1273: /* DEFINT_1 */
		break;
		case 1274: /* DEFINT_4 */
		break;
		case 1275: /* DEFINT_8 */
		break;
	default:
		if( a.getOperator() > 1275) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label(ITree a) {
	int c;
	State ts;

	if( a == null ) throw new System.Exception("label: null tree");
	State p = new State();
	a.setState(p);
	p.cost[1] = 0x7FFF;
	p.cost[2] = 0x7FFF;
	p.cost[3] = 0x7FFF;
	p.cost[4] = 0x7FFF;
	p.cost[5] = 0x7FFF;
	p.cost[6] = 0x7FFF;
	p.cost[7] = 0x7FFF;
	p.cost[8] = 0x7FFF;
	p.cost[9] = 0x7FFF;
	p.cost[10] = 0x7FFF;
	p.cost[11] = 0x7FFF;
	p.cost[12] = 0x7FFF;
	p.cost[13] = 0x7FFF;
	p.cost[14] = 0x7FFF;
	p.cost[15] = 0x7FFF;
	p.cost[16] = 0x7FFF;
	p.cost[17] = 0x7FFF;
	int o = a.getOperator();
	if( o < 50) { label0(a,p); }
	else if( o < 100) { label1(a,p); }
	else if( o < 150) { label2(a,p); }
	else if( o < 200) { label3(a,p); }
	else if( o < 250) { label4(a,p); }
	else if( o < 300) { label5(a,p); }
	else if( o < 350) { label6(a,p); }
	else if( o < 400) { label7(a,p); }
	else if( o < 450) { label8(a,p); }
	else if( o < 500) { label9(a,p); }
	else if( o < 550) { label10(a,p); }
	else if( o < 600) { label11(a,p); }
	else if( o < 650) { label12(a,p); }
	else if( o < 700) { label13(a,p); }
	else if( o < 750) { label14(a,p); }
	else if( o < 800) { label15(a,p); }
	else if( o < 850) { label16(a,p); }
	else if( o < 900) { label17(a,p); }
	else if( o < 950) { label18(a,p); }
	else if( o < 1000) { label19(a,p); }
	else if( o < 1050) { label20(a,p); }
	else if( o < 1100) { label21(a,p); }
	else if( o < 1150) { label22(a,p); }
	else if( o < 1200) { label23(a,p); }
	else if( o < 1250) { label24(a,p); }
	else label25(a,p); }
ITree[] kids( ITree p, int eruleno ) {
	ITree[] result;
	if( p == null ) throw new System.Exception("kids: null tree");
	switch( eruleno ) {
	case
	229/* [NEW_FINALIZE_0 t immed] -> t 229 */,
	228/* [NEW_0 t immed] -> t 228 */,
	226/* [BOUNDS_R_0 tv tv] -> inst 226 */,
	225/* [BOUNDS_0 tv tv] -> tv 225 */,
	205/* [ADD_4 index base] -> addr 205 */,
	204/* [ADD_4 base index] -> addr 204 */,
	202/* [MUL_4 const tv] -> index 202 */,
	201/* [MUL_4 tv const] -> index 201 */,
	198/* [ADD_4 tv const] -> base 198 */,
	197/* [ADD_4 const tv] -> base 197 */,
	185/* [SEQ_1 inst tv] -> tv 185 */,
	184/* [SEQ_4 inst tv] -> tv 184 */,
	183/* [PARAM1_4 t param] -> param 183 */,
	182/* [PARAM0_4 t param] -> param 182 */,
	178/* [ARG1_4 t arg] -> arg 178 */,
	177/* [ARG0_4 t arg] -> arg 177 */,
	168/* [SEQ_4 inst global] -> global 168 */,
	167/* [SEQ_4 inst immed] -> immed 167 */,
	163/* [SEQ_4 inst const] -> const 163 */,
	156/* [END_FINALLY_0 t t] -> inst 156 */,
	155/* [COND_RETHROW_0 t t] -> inst 155 */,
	140/* [ADD_4 global const] -> const 140 */,
	139/* [ADD_4 const global] -> const 139 */,
	121/* [LEU_1 tvi tvm] -> compare 121 */,
	120/* [LEU_1 tvm tvi] -> compare 120 */,
	119/* [GEU_1 tvi tvm] -> compare 119 */,
	118/* [GEU_1 tvm tvi] -> compare 118 */,
	117/* [LTU_1 tvi tvm] -> compare 117 */,
	116/* [LTU_1 tvm tvi] -> compare 116 */,
	115/* [GTU_1 tvi tvm] -> compare 115 */,
	114/* [GTU_1 tvm tvi] -> compare 114 */,
	113/* [LE_1 tvi tvm] -> compare 113 */,
	112/* [LE_1 tvm tvi] -> compare 112 */,
	111/* [GE_1 tvi tvm] -> compare 111 */,
	110/* [GE_1 tvm tvi] -> compare 110 */,
	109/* [LT_1 tvi tvm] -> compare 109 */,
	108/* [LT_1 tvm tvi] -> compare 108 */,
	107/* [GT_1 tvi tvm] -> compare 107 */,
	106/* [GT_1 tvm tvi] -> compare 106 */,
	105/* [NE_1 tvi tvm] -> compare 105 */,
	104/* [NE_1 tvm tvi] -> compare 104 */,
	103/* [EQ_1 tvi tvm] -> compare 103 */,
	102/* [EQ_1 tvm tvi] -> compare 102 */,
	101/* [LEU_4 tvi tvm] -> compare 101 */,
	100/* [LEU_4 tvm tvi] -> compare 100 */,
	99/* [GEU_4 tvi tvm] -> compare 99 */,
	98/* [GEU_4 tvm tvi] -> compare 98 */,
	97/* [LTU_4 tvi tvm] -> compare 97 */,
	96/* [LTU_4 tvm tvi] -> compare 96 */,
	95/* [GTU_4 tvi tvm] -> compare 95 */,
	94/* [GTU_4 tvm tvi] -> compare 94 */,
	93/* [LE_4 tvi tvm] -> compare 93 */,
	92/* [LE_4 tvm tvi] -> compare 92 */,
	91/* [GE_4 tvi tvm] -> compare 91 */,
	90/* [GE_4 tvm tvi] -> compare 90 */,
	89/* [LT_4 tvi tvm] -> compare 89 */,
	88/* [LT_4 tvm tvi] -> compare 88 */,
	87/* [GT_4 tvi tvm] -> compare 87 */,
	86/* [GT_4 tvm tvi] -> compare 86 */,
	85/* [NE_4 tvi tvm] -> compare 85 */,
	84/* [NE_4 tvm tvi] -> compare 84 */,
	83/* [EQ_4 tvi tvm] -> compare 83 */,
	82/* [EQ_4 tvm tvi] -> compare 82 */,
	59/* [COPY_1 tvm tvi] -> inst 59 */,
	58/* [COPY_4 tvm tvi] -> inst 58 */,
	43/* [LEA_4 t addr] -> inst 43 */,
	38/* [SHAR_1 t tv] -> t 38 */,
	37/* [SHL_1 t tv] -> t 37 */,
	36/* [XOR_1 tvmi t] -> t 36 */,
	35/* [XOR_1 t tvmi] -> t 35 */,
	34/* [OR_1 tvmi t] -> t 34 */,
	33/* [OR_1 t tvmi] -> t 33 */,
	32/* [AND_1 tvmi t] -> t 32 */,
	31/* [AND_1 t tvmi] -> t 31 */,
	30/* [MOD_1 t tvm] -> t 30 */,
	29/* [DIV_1 t tvm] -> t 29 */,
	28/* [MUL_1 immed tvm] -> t 28 */,
	27/* [MUL_1 tvm immed] -> t 27 */,
	26/* [MUL_1 tvmi t] -> t 26 */,
	25/* [MUL_1 t tvmi] -> t 25 */,
	24/* [SUB_1 t tvmi] -> t 24 */,
	23/* [ADD_1 tvmi t] -> t 23 */,
	22/* [ADD_1 t tvmi] -> t 22 */,
	19/* [SHAR_4 t tv] -> t 19 */,
	18/* [SHL_4 t tv] -> t 18 */,
	17/* [XOR_4 tvmi t] -> t 17 */,
	16/* [XOR_4 t tvmi] -> t 16 */,
	15/* [OR_4 tvmi t] -> t 15 */,
	14/* [OR_4 t tvmi] -> t 14 */,
	13/* [AND_4 tvmi t] -> t 13 */,
	12/* [AND_4 t tvmi] -> t 12 */,
	11/* [MOD_4 t tvm] -> t 11 */,
	10/* [DIV_4 t tvm] -> t 10 */,
	9/* [MUL_4 immed tvm] -> t 9 */,
	8/* [MUL_4 tvm immed] -> t 8 */,
	7/* [MUL_4 tvmi t] -> t 7 */,
	6/* [MUL_4 t tvmi] -> t 6 */,
	5/* [SUB_4 t tvmi] -> t 5 */,
	4/* [ADD_4 tvmi t] -> t 4 */,
	3/* [ADD_4 t tvmi] -> t 3 */,
	1/* [LIST_0 inst inst] -> inst 1 */:
		result = new ITree[2];
		result[0] = p.getLeft();
		result[1] = p.getRight();

	case
	238/* DUMMY_JUMP_0 -> inst 238 */,
	236/* CALL_0 -> inst 236 */,
	235/* DYNAMIC_CALL_DISCARD_0 -> inst 235 */,
	233/* STATIC_CALL_DISCARD_0 -> inst 233 */,
	227/* BOUNDS_L_0 -> inst 227 */,
	224/* LEAVE_LOOP_0 -> inst 224 */,
	223/* ENTER_LOOP_0 -> inst 223 */,
	222/* RET_0 -> inst 222 */,
	221/* RET_0 -> inst 221 */,
	220/* START_CATCH_0 -> inst 220 */,
	218/* RELEASE_0 -> inst 218 */,
	217/* RESERVE_0 -> inst 217 */,
	216/* RESTORE_ALL_0 -> inst 216 */,
	215/* SAVE_ALL_0 -> inst 215 */,
	214/* EXTERN_0 -> inst 214 */,
	213/* DLABEL_0 -> inst 213 */,
	212/* LABEL_0 -> inst 212 */,
	211/* LEAVE_0 -> inst 211 */,
	210/* ENTER_0 -> inst 210 */,
	209/* LOCAL_1 -> addr 209 */,
	208/* LOCAL_4 -> addr 208 */,
	187/* REG_VAR_1 -> v 187 */,
	186/* REG_VAR_4 -> v 186 */,
	179/* COMMENT_0 -> param 179 */,
	175/* COMMENT_0 -> arg 175 */,
	174/* REGISTER_1 -> t 174 */,
	173/* REGISTER_4 -> t 173 */,
	172/* TEMP_1 -> t 172 */,
	171/* TEMP_4 -> t 171 */,
	166/* CONST_1 -> immed 166 */,
	165/* CONST_4 -> immed 165 */,
	164/* GLOBAL_4 -> immed 164 */,
	162/* DLABEL_0 -> const 162 */,
	161/* LABEL_0 -> const 161 */,
	160/* CONST_4 -> const 160 */,
	159/* GLOBAL_4 -> const 159 */,
	158/* GLOBAL_4 -> global 158 */,
	157/* SUSPEND_CATCH_0 -> inst 157 */,
	154/* END_CATCH_0 -> inst 154 */,
	153/* END_TRY_0 -> inst 153 */,
	152/* TRY_0 -> inst 152 */,
	151/* RODATA_0 -> inst 151 */,
	150/* DATA_0 -> inst 150 */,
	149/* TEXT_0 -> inst 149 */,
	148/* STATIC_0 -> inst 148 */,
	147/* POPSEG_0 -> inst 147 */,
	146/* PUSHSEG_0 -> inst 146 */,
	143/* CONST_CSTR_0 -> immed 143 */,
	142/* CONST_STR_0 -> immed 142 */,
	138/* JUMP_0 -> inst 138 */,
	133/* LINE_0 -> inst 133 */,
	2/* COMMENT_0 -> inst 2 */:
		result = new ITree[0];

	case
	237/* [THROW_4 t] -> inst 237 */,
	234/* [DYNAMIC_CALL_0 t] -> inst 234 */,
	232/* [STATIC_CALL_0 t] -> inst 232 */,
	231/* [NEW_ARRAY_0 t] -> t 231 */,
	230/* [NEW_OBJ_ARRAY_0 t] -> t 230 */,
	219/* [THROW_RETURN_4 tv] -> inst 219 */,
	180/* [RESULT_4 t] -> param 180 */,
	170/* [INDIRECT_1 addr] -> mem 170 */,
	169/* [INDIRECT_4 addr] -> mem 169 */,
	145/* [RESULT_F_0 t] -> inst 145 */,
	144/* [RESULT_4 t] -> inst 144 */,
	141/* [BOX_0 t] -> t 141 */,
	137/* [BRANCHNZ_1 tvm] -> inst 137 */,
	136/* [BRANCHZ_1 tvm] -> inst 136 */,
	135/* [BRANCHNZ_4 tvm] -> inst 135 */,
	134/* [BRANCHZ_4 tvm] -> inst 134 */,
	132/* [BRANCHNZ_1 const] -> inst 132 */,
	131/* [BRANCHNZ_1 const] -> inst 131 */,
	130/* [BRANCHZ_1 const] -> inst 130 */,
	129/* [BRANCHZ_1 const] -> inst 129 */,
	128/* [BRANCHNZ_4 const] -> inst 128 */,
	127/* [BRANCHNZ_4 const] -> inst 127 */,
	126/* [BRANCHZ_4 const] -> inst 126 */,
	125/* [BRANCHZ_4 const] -> inst 125 */,
	124/* [BRANCH_0 compare] -> inst 124 */,
	123/* [DECBNN_4 tvm] -> inst 123 */,
	61/* [POP_4 tvm] -> inst 61 */,
	60/* [PUSH_4 tvmi] -> inst 60 */,
	55/* [CAST_CHECK_0 tv] -> tv 55 */,
	54/* [TREAT_AS_1 tvmi] -> tvmi 54 */,
	53/* [TREAT_AS_4 tvmi] -> tvmi 53 */,
	52/* [CAST_FROM4_1 t] -> t 52 */,
	51/* [CAST_FROM4_1 mem] -> mem 51 */,
	50/* [CAST_FROM4_1 immed] -> immed 50 */,
	49/* [CAST_FROM1_4 tvm] -> tv 49 */,
	48/* [CAST_FROM1_4 immed] -> immed 48 */,
	47/* [CAST_FROM4_4 mem] -> mem 47 */,
	46/* [CAST_FROM4_4 tv] -> tv 46 */,
	45/* [CAST_FROM4_4 t] -> t 45 */,
	44/* [CAST_FROM4_4 immed] -> immed 44 */,
	40/* [NOT_1 t] -> t 40 */,
	39/* [NEG_1 t] -> t 39 */,
	21/* [NOT_4 t] -> t 21 */,
	20/* [NEG_4 t] -> t 20 */:
		result = new ITree[1];
		result[0] = p.getLeft();

	case
	207/* index -> addr 207 */,
	206/* base -> addr 206 */,
	203/* tv -> index 203 */,
	200/* const -> base 200 */,
	199/* tv -> base 199 */,
	196/* tv -> inst 196 */,
	195/* immed -> tvi 195 */,
	194/* tv -> tvi 194 */,
	193/* v -> tv 193 */,
	192/* t -> tv 192 */,
	191/* immed -> tvmi 191 */,
	190/* tvm -> tvmi 190 */,
	189/* tv -> tvm 189 */,
	188/* mem -> tvm 188 */,
	181/* param -> inst 181 */,
	176/* arg -> inst 176 */,
	122/* compare -> t 122 */,
	42/* addr -> t 42 */,
	41/* tvmi -> t 41 */:
		result = new ITree[1];
		result[0] = p;

	case
	57/* [OBJ_NE_0 [PAIR_4 tv tv] tv] -> inst 57 */,
	56/* [OBJ_EQ_0 [PAIR_4 tv tv] tv] -> inst 56 */:
		result = new ITree[3];
		result[0] = p.getLeft().getLeft();
		result[1] = p.getLeft().getRight();
		result[2] = p.getRight();

	case
	81/* [COPY_1 tv [MUL_1 tvmi tv]] -> inst 81 */,
	80/* [COPY_1 tv [MUL_1 tv tvmi]] -> inst 80 */,
	79/* [COPY_1 tvm [SUB_1 tvi tvm]] -> inst 79 */,
	78/* [COPY_1 tvm [SUB_1 tvm tvi]] -> inst 78 */,
	77/* [COPY_1 tvm [OR_1 tvi tvm]] -> inst 77 */,
	76/* [COPY_1 tvm [OR_1 tvm tvi]] -> inst 76 */,
	75/* [COPY_1 tvm [AND_1 tvi tvm]] -> inst 75 */,
	74/* [COPY_1 tvm [AND_1 tvm tvi]] -> inst 74 */,
	73/* [COPY_1 tvm [ADD_1 tvi tvm]] -> inst 73 */,
	72/* [COPY_1 tvm [ADD_1 tvm tvi]] -> inst 72 */,
	71/* [COPY_4 tv [MUL_4 tvmi tv]] -> inst 71 */,
	70/* [COPY_4 tv [MUL_4 tv tvmi]] -> inst 70 */,
	69/* [COPY_4 tvm [SUB_4 tvi tvm]] -> inst 69 */,
	68/* [COPY_4 tvm [SUB_4 tvm tvi]] -> inst 68 */,
	67/* [COPY_4 tvm [OR_4 tvi tvm]] -> inst 67 */,
	66/* [COPY_4 tvm [OR_4 tvm tvi]] -> inst 66 */,
	65/* [COPY_4 tvm [AND_4 tvi tvm]] -> inst 65 */,
	64/* [COPY_4 tvm [AND_4 tvm tvi]] -> inst 64 */,
	63/* [COPY_4 tvm [ADD_4 tvi tvm]] -> inst 63 */,
	62/* [COPY_4 tvm [ADD_4 tvm tvi]] -> inst 62 */:
		result = new ITree[3];
		result[0] = p.getLeft();
		result[1] = p.getRight().getLeft();
		result[2] = p.getRight().getRight();

	default:
		throw new System.Exception("kids: bad rule number " + eruleno );
	}
	return result;
}
}
class ITreeFactory {
	ITree create(ITree node, ITree[] children) {
		return null;
	}
	void init() {}
}
class ITreeFactory1 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,(children[0]),(children[1]));

	}
}
class ITreeFactory2 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT_0,0,node.getValue());

	}
}
class ITreeFactory3 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.ADD2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory4 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.ADD2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory5 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.SUB2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory6 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.MUL2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory7 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.MUL2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory8 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.MUL,4,(children[0]),(children[1]))),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory9 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.MUL,4,(children[1]),(children[0]))),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory10 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.DIV,4,new ITree(0,Op.PAIR,4,(children[0]),(children[1])),new ITree(0,Op.TEMP,4,temp_t)),(children[0]).getTemp());

	}
}
class ITreeFactory11 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.MOD,4,new ITree(0,Op.PAIR,4,new ITree(0,Op.TEMP,4,temp_t),(children[0])),(children[1])),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory12 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.AND2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory13 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.AND2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory14 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.OR2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory15 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.OR2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory16 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.XOR2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory17 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.XOR2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory18 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.SHL,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory19 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.SHAR,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory20 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.NEG,4,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory21 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.NOT,4,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory22 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.ADD2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory23 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.ADD2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory24 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.SUB2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory25 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.MUL2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory26 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.MUL2,1,(children[1]),(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory27 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.COPY,1,new ITree(0,Op.TEMP,1,temp_t),new ITree(0,Op.MUL,1,(children[0]),(children[1]))),new ITree(0,Op.TEMP,1,temp_t));

	}
}
class ITreeFactory28 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.COPY,1,new ITree(0,Op.TEMP,1,temp_t),new ITree(0,Op.MUL,1,(children[1]),(children[0]))),new ITree(0,Op.TEMP,1,temp_t));

	}
}
class ITreeFactory29 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.DIV,1,new ITree(0,Op.PAIR,1,(children[0]),(children[1])),new ITree(0,Op.TEMP,1,temp_t)),(children[0]).getTemp());

	}
}
class ITreeFactory30 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.MOD,1,new ITree(0,Op.PAIR,1,new ITree(0,Op.TEMP,1,temp_t),(children[0])),(children[1])),new ITree(0,Op.TEMP,1,temp_t));

	}
}
class ITreeFactory31 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.AND2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory32 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.AND2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory33 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.OR2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory34 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.OR2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory35 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.XOR2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory36 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.XOR2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory37 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.SHL,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory38 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.SHAR,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory39 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.NEG,1,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory40 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.NOT,1,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory41 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
            int size = children[0].getSize(); int temp_t = ITree.nextTemp(); return new ITree(0,Op.SEQ,size,new ITree(0,Op.COPY,size,new ITree(0,Op.TEMP,size,temp_t),(children[0])),new ITree(0,Op.TEMP,size,temp_t)); ;

	}
}
class ITreeFactory42 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.LEA,4,new ITree(0,Op.TEMP,4,temp_t),(children[0])),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory43 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LEA,4,(children[0]),(children[1]));

	}
}
class ITreeFactory44 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory45 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory46 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory47 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory48 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory49 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.CAST_FROM1,4,new ITree(0,Op.TEMP,4,temp_t),(children[0])),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory50 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory51 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory52 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_1,1,new ITree(0,Op.TREAT_AS_1,1,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory53 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory54 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory55 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
	int temp_m = Gen.TempFactory.nextLabelNumber();
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),(children[0])),new ITree(0,Op.BRANCHZ,4,new ITree(0,Op.TEMP,4,temp_t),".L"+temp_m).rewrite(),new ITree(0,Op.LABEL,0,".L"+temp_l),new ITree(0,Op.BRANCH,0,new ITree(0,Op.EQ,4,new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,0),new ITree(0,Op.TEMP,4,temp_t))),new ITree(0,Op.CONST,4,node.getValue())),".L"+temp_m).rewrite(),new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,0),new ITree(0,Op.TEMP,4,temp_t)))),new ITree(0,Op.BRANCHNZ,4,new ITree(0,Op.TEMP,4,temp_t),".L"+temp_l).rewrite(),new ITree(0,Op.CALL,0,"__throw_castexception"),new ITree(0,Op.LABEL,0,".L"+temp_m)),(children[0]).getTemp());

	}
}
class ITreeFactory56 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY_4,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,1)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_t),node.getString()),new ITree(0,Op.COPY_4,4,new ITree(0,Op.TEMP,4,temp_u),new ITree(0,Op.CMP_4,4,(children[0]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,0)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_u),node.getString()),new ITree(0,Op.COPY_4,4,new ITree(0,Op.TEMP,4,temp_u),new ITree(0,Op.CMP_4,4,(children[1]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_u),node.getString()));

	}
}
class ITreeFactory57 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY_4,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,0)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_t),node.getString()),new ITree(0,Op.COPY_4,4,new ITree(0,Op.TEMP,4,temp_u),new ITree(0,Op.CMP_4,4,(children[0]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,1)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_u),node.getString()),new ITree(0,Op.COPY_4,4,new ITree(0,Op.TEMP,4,temp_u),new ITree(0,Op.CMP_4,4,(children[1]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_u),node.getString()));

	}
}
class ITreeFactory58 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_4,4,(children[0]),(children[1]));

	}
}
class ITreeFactory59 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_1,1,(children[0]),(children[1]));

	}
}
class ITreeFactory60 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PUSH_4,4,(children[0]));

	}
}
class ITreeFactory61 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.POP_4,4,(children[0]));

	}
}
class ITreeFactory62 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2_4,4,(children[1]),(children[2]));

	}
}
class ITreeFactory63 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2_4,4,(children[2]),(children[1]));

	}
}
class ITreeFactory64 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2_4,4,(children[1]),(children[2]));

	}
}
class ITreeFactory65 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2_4,4,(children[2]),(children[1]));

	}
}
class ITreeFactory66 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2_4,4,(children[1]),(children[2]));

	}
}
class ITreeFactory67 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2_4,4,(children[2]),(children[1]));

	}
}
class ITreeFactory68 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUB2_4,4,(children[1]),(children[2]));

	}
}
class ITreeFactory69 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUBR2_4,4,(children[2]),(children[1]));

	}
}
class ITreeFactory70 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2_4,4,(children[1]),(children[2]));

	}
}
class ITreeFactory71 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2_4,4,(children[2]),(children[1]));

	}
}
class ITreeFactory72 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2_1,1,(children[1]),(children[2]));

	}
}
class ITreeFactory73 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2_1,1,(children[2]),(children[1]));

	}
}
class ITreeFactory74 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2_1,1,(children[1]),(children[2]));

	}
}
class ITreeFactory75 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2_1,1,(children[2]),(children[1]));

	}
}
class ITreeFactory76 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2_1,1,(children[1]),(children[2]));

	}
}
class ITreeFactory77 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2_1,1,(children[2]),(children[1]));

	}
}
class ITreeFactory78 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUB2_1,1,(children[1]),(children[2]));

	}
}
class ITreeFactory79 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUBR2_1,1,(children[2]),(children[1]));

	}
}
class ITreeFactory80 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2_1,1,(children[1]),(children[2]));

	}
}
class ITreeFactory81 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2_1,1,(children[2]),(children[1]));

	}
}
class ITreeFactory82 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory83 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory84 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JNE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory85 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JNE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory86 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JG)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory87 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JL)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory88 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JL)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory89 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JG)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory90 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JGE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory91 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JLE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory92 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JLE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory93 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JGE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory94 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JGU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory95 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JLU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory96 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JLU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory97 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JGU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory98 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JGEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory99 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JLEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory100 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),(children[1]),Op.JLEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory101 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[1]),(children[0]),Op.JGEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory102 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory103 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory104 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JNE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory105 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JNE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory106 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JG)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory107 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JL)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory108 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JL)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory109 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JG)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory110 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JGE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory111 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JLE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory112 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JLE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory113 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JGE)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory114 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JGU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory115 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JLU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory116 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JLU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory117 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JGU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory118 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JGEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory119 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JLEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory120 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),(children[1]),Op.JLEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory121 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[1]),(children[0]),Op.JGEU)),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory122 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,children[0].getLeft().getRight().getInt()-Op.JE+Op.SETE_1,1,new ITree(0,Op.TEMP,1,temp_t),(children[0])),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory123 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DECBNN_4,4,(children[0]),node.getString());

	}
}
class ITreeFactory124 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,(children[0]).getLeft().getRight().getInt(),0,(children[0]),node.getString());

	}
}
class ITreeFactory125 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.NOP,0);

	}
}
class ITreeFactory126 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory127 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory128 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.NOP,0);

	}
}
class ITreeFactory129 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.NOP,0);

	}
}
class ITreeFactory130 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory131 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory132 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.NOP,0);

	}
}
class ITreeFactory133 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.UNWIND,0),new ITree(0,Op.DEFINT,4,".L"+temp_l),new ITree(0,Op.DEFINT,4,node.getString()),new ITree(0,Op.POPSEG,0),new ITree(0,Op.LINE,0,node.getString()));

	}
}
class ITreeFactory134 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JE,0,new ITree(0,Op.SEQ,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.TEMP,4,temp_t)),node.getString());

	}
}
class ITreeFactory135 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JNE,0,new ITree(0,Op.SEQ,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_4,4,(children[0]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.TEMP,4,temp_t)),node.getString());

	}
}
class ITreeFactory136 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JE,0,new ITree(0,Op.SEQ,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),new ITree(0,Op.CONST,1,0))),new ITree(0,Op.TEMP,4,temp_t)),node.getString());

	}
}
class ITreeFactory137 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JNE,0,new ITree(0,Op.SEQ,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP_1,1,(children[0]),new ITree(0,Op.CONST,1,0))),new ITree(0,Op.TEMP,4,temp_t)),node.getString());

	}
}
class ITreeFactory138 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory139 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RELOC,0,(children[1]),(children[0]));

	}
}
class ITreeFactory140 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RELOC,0,(children[0]),(children[1]));

	}
}
class ITreeFactory141 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.ARG0,4,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")),new ITree(0,Op.CALL,0,new ITree(0,Op.TEMP,4,temp_t),"box$integer")),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory142 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
	int temp_m = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.RODATA,0),new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.CONST_CSTR,0,node.getString()),new ITree(0,Op.DLABEL,0,".L"+temp_m),new ITree(0,Op.DEFINT,4,"vtable$__Q26System6String"),new ITree(0,Op.DEFINT,4,".L"+temp_l),new ITree(0,Op.DEFINT,4,node.getString().getLength()),new ITree(0,Op.POPSEG,0)),new ITree(0,Op.GLOBAL,4,".L"+temp_m));

	}
}
class ITreeFactory143 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.RODATA,0),new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.CONST_CSTR,0,node.getString()),new ITree(0,Op.POPSEG,0)),new ITree(0,Op.GLOBAL,4,".L"+temp_l));

	}
}
class ITreeFactory144 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.RESULT,4,(children[0])),new ITree(0,Op.JUMP,0,node.getString()));

	}
}
class ITreeFactory145 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RESULT,4,(children[0]));

	}
}
class ITreeFactory146 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PUSHSEG_0,0,node.getValue());

	}
}
class ITreeFactory147 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.POPSEG_0,0,node.getValue());

	}
}
class ITreeFactory148 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.STATIC_0,0,node.getValue());

	}
}
class ITreeFactory149 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEXT_0,0,node.getValue());

	}
}
class ITreeFactory150 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DATA_0,0,node.getValue());

	}
}
class ITreeFactory151 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RODATA_0,0,node.getValue());

	}
}
class ITreeFactory152 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY,4,new ITree(0,Op.INDIRECT,4,new ITree(0,Op.GLOBAL,4,"%gs:__exception_top@NTPOFF")),new ITree(0,Op.CONST,4,node.getString()));

	}
}
class ITreeFactory153 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COMMENT,0,"try block completed without encountering exception. Excecute finally and continue"),new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CONST,4,"0")),new ITree(0,Op.ARG0,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.COMMENT,0,"finally")));

	}
}
class ITreeFactory154 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COMMENT,0,"exception handled - throw a stop exception to outer handler"),new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CONST,4,"0")),new ITree(0,Op.ARG0,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.COMMENT,0,"finally")),new ITree(0,Op.JUMP,0,node.getString()));

	}
}
class ITreeFactory155 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP,4,(children[0]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.ARG0,4,(children[0]).getTemp(),new ITree(0,Op.ARG1,4,(children[1]),new ITree(0,Op.COMMENT,0,"conditional rethrow"))),new ITree(0,Op.COMMENT,0,"exception not handled - throw unhandled exception to outer handler"),new ITree(0,Op.JNE,0,new ITree(0,Op.TEMP,4,temp_t),node.getString()),new ITree(0,Op.COMMENT,0,"exception handled - fall through to enclosing code"));

	}
}
class ITreeFactory156 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CMP,4,(children[0]),new ITree(0,Op.CONST,4,3))),new ITree(0,Op.RESULT,4,(children[1])),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_t),node.getString()),new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_u),new ITree(0,Op.CMP,4,(children[0]).getTemp(),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,4,temp_u),".L"+temp_l),new ITree(0,Op.ARG0,4,(children[0]).getTemp(),new ITree(0,Op.ARG1,4,(children[1]).getTemp(),new ITree(0,Op.COMMENT,0,"conditional rethrow"))),new ITree(0,Op.CALL,0,"__throw_endfinally"),new ITree(0,Op.LABEL,0,".L"+temp_l));

	}
}
class ITreeFactory157 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY,4,new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,20),new ITree(0,Op.REGISTER,4,8))),new ITree(0,Op.CONST,4,"-1"));

	}
}
class ITreeFactory158 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.GLOBAL_4,4,node.getValue());

	}
}
class ITreeFactory159 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.GLOBAL_4,4,node.getValue());

	}
}
class ITreeFactory160 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CONST_4,4,node.getValue());

	}
}
class ITreeFactory161 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LABEL_0,0,node.getValue());

	}
}
class ITreeFactory162 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DLABEL_0,0,node.getValue());

	}
}
class ITreeFactory163 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory164 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.GLOBAL_4,4,node.getValue());

	}
}
class ITreeFactory165 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CONST_4,4,node.getValue());

	}
}
class ITreeFactory166 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CONST_1,1,node.getValue());

	}
}
class ITreeFactory167 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory168 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory169 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.INDIRECT_4,4,(children[0]),node.getValue());

	}
}
class ITreeFactory170 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.INDIRECT_1,1,(children[0]),node.getValue());

	}
}
class ITreeFactory171 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP_4,4,node.getValue());

	}
}
class ITreeFactory172 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP_1,1,node.getValue());

	}
}
class ITreeFactory173 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.REGISTER_4,4,node.getValue());

	}
}
class ITreeFactory174 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.REGISTER_1,1,node.getValue());

	}
}
class ITreeFactory175 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT_0,0,node.getValue());

	}
}
class ITreeFactory176 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory177 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG0_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory178 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG1_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory179 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT_0,0,node.getValue());

	}
}
class ITreeFactory180 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RESULT_4,4,(children[0]),node.getValue());

	}
}
class ITreeFactory181 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory182 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM0_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory183 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM1_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory184 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,(children[0]),(children[1]));

	}
}
class ITreeFactory185 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,(children[0]),(children[1]));

	}
}
class ITreeFactory186 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP,4,node.getInt());

	}
}
class ITreeFactory187 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP,1,node.getInt());

	}
}
class ITreeFactory188 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory189 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory190 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory191 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory192 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory193 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory194 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory195 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory196 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory197 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,4,(children[0]),(children[1]));

	}
}
class ITreeFactory198 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,4,(children[1]),(children[0]));

	}
}
class ITreeFactory199 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD_4,4,new ITree(0,Op.CONST,4,"0"),(children[0]));

	}
}
class ITreeFactory200 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory201 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL,4,(children[0]),(children[1]));

	}
}
class ITreeFactory202 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL,4,(children[1]),(children[0]));

	}
}
class ITreeFactory203 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL_4,4,(children[0]),new ITree(0,Op.CONST,4,"1"));

	}
}
class ITreeFactory204 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD_4,4,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory205 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,4,(children[1]),(children[0]));

	}
}
class ITreeFactory206 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory207 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory208 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD_4,4,new ITree(0,Op.CONST,4,(node.getValue())),new ITree(0,Op.REGISTER,4,7));

	}
}
class ITreeFactory209 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD_4,4,new ITree(0,Op.CONST,4,(node.getValue())),new ITree(0,Op.REGISTER,4,7));

	}
}
class ITreeFactory210 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ENTER_0,0,node.getValue());

	}
}
class ITreeFactory211 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LEAVE_0,0,node.getValue());

	}
}
class ITreeFactory212 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LABEL_0,0,node.getValue());

	}
}
class ITreeFactory213 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DLABEL_0,0,node.getValue());

	}
}
class ITreeFactory214 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.EXTERN_0,0,node.getValue());

	}
}
class ITreeFactory215 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SAVE_ALL_0,0,node.getValue());

	}
}
class ITreeFactory216 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RESTORE_ALL_0,0,node.getValue());

	}
}
class ITreeFactory217 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUB2,4,new ITree(0,Op.REGISTER,4,8),new ITree(0,Op.CONST,4,node.getString()));

	}
}
class ITreeFactory218 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,4,new ITree(0,Op.REGISTER,4,8),new ITree(0,Op.CONST,4,node.getString()));

	}
}
class ITreeFactory219 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COMMENT,0,"throw return"),new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.CONST,4,"3")),new ITree(0,Op.ARG0,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.ARG1,4,(children[0]),new ITree(0,Op.COMMENT,0,"throw return"))),new ITree(0,Op.JUMP,0,node.getValue()));

	}
}
class ITreeFactory220 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY,4,new ITree(0,Op.INDIRECT,4,new ITree(0,Op.GLOBAL,4,"%gs:__exception_top@NTPOFF")),new ITree(0,Op.REGISTER,4,8));

	}
}
class ITreeFactory221 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RET_0,0,node.getValue());

	}
}
class ITreeFactory222 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RET_0,0,node.getValue());

	}
}
class ITreeFactory223 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ENTER_LOOP_0,0,node.getValue());

	}
}
class ITreeFactory224 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LEAVE_LOOP_0,0,node.getValue());

	}
}
class ITreeFactory225 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.SEQ_4,4,new ITree(0,Op.LIST,0,new ITree(0,Op.BRANCH,0,new ITree(0,Op.LTU,4,(children[1]),new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,"4"),(children[0])))),".L"+temp_l).rewrite(),new ITree(0,Op.CALL,0,"__throw_arrayboundsexception"),new ITree(0,Op.LABEL,0,".L"+temp_l)),(children[1]).getTemp());

	}
}
class ITreeFactory226 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.BRANCH,0,new ITree(0,Op.GEU,4,(children[1]),new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,"4"),(children[0])))),node.getString()).rewrite();

	}
}
class ITreeFactory227 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.LABEL,0,node.getString()),new ITree(0,Op.CALL,0,"__throw_arrayboundsexception"));

	}
}
class ITreeFactory228 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),(children[1])),new ITree(0,Op.PUSH_4,4,new ITree(0,Op.TEMP,4,temp_t)),new ITree(0,Op.PUSH_4,4,(children[0])),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,4,temp_u),"__alloc_object"),new ITree(0,Op.ADD2,4,new ITree(0,Op.REGISTER,4,8),new ITree(0,Op.CONST,4,"8"))),new ITree(0,Op.TEMP,4,temp_u));

	}
}
class ITreeFactory229 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),(children[1])),new ITree(0,Op.PUSH_4,4,new ITree(0,Op.TEMP,4,temp_t)),new ITree(0,Op.PUSH_4,4,(children[0])),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,4,temp_u),"__alloc_object_finalize"),new ITree(0,Op.ADD2,4,new ITree(0,Op.REGISTER,4,8),new ITree(0,Op.CONST,4,"8"))),new ITree(0,Op.TEMP,4,temp_u));

	}
}
class ITreeFactory230 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.ARG0,4,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,4,temp_t),"allocao")),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory231 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.LIST,0,new ITree(0,Op.ARG0,4,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")),new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_u),new ITree(0,Op.CONST,4,node.getString())),new ITree(0,Op.ARG1,4,new ITree(0,Op.TEMP,4,temp_u),new ITree(0,Op.COMMENT,0,"last arg")),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,4,temp_t),"alloca")),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory232 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.STATIC_CALL,0,(children[0]).getTemp(),node.getString());

	}
}
class ITreeFactory233 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.STATIC_CALL_DISCARD,0,node.getString());

	}
}
class ITreeFactory234 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,4,(children[0]).getTemp(),new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,"0"),new ITree(0,Op.REGISTER,4,3)))),new ITree(0,Op.DYNAMIC_CALL,0,(children[0]).getTemp(),new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,node.getString()),(children[0]).getTemp()))));

	}
}
class ITreeFactory235 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,4,new ITree(0,Op.REGISTER,4,1),new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,"0"),new ITree(0,Op.REGISTER,4,3)))),new ITree(0,Op.DYNAMIC_CALL_DISCARD,0,new ITree(0,Op.INDIRECT,4,new ITree(0,Op.ADD,4,new ITree(0,Op.CONST,4,node.getString()),new ITree(0,Op.REGISTER,4,1)))));

	}
}
class ITreeFactory236 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CALL,0,node.getString());

	}
}
class ITreeFactory237 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.ARG0,4,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")),new ITree(0,Op.CALL,0,"__throw_exception"));

	}
}
class ITreeFactory238 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DUMMY_JUMP_0,0,node.getValue());

	}
}
}
