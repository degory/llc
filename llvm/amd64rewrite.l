namespace ReWrite {
use Gen.ITree; use Gen.IString; use Gen.INumber;
class State extends System.Object {
	public int[] cost;
	public int[] rule;
	void init() { super.init(); cost = new int[17]; rule = new int[17]; }
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
public const int arg_NT = 12;
public const int param_NT = 13;
public const int v_NT = 14;
public const int base_NT = 15;
public const int index_NT = 16;

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
int[] decode_arg;
int[] decode_param;
int[] decode_v;
int[] decode_base;
int[] decode_index;
int rule( State state, int goalnt) {
	if( goalnt < 1 || goalnt > 16) throw new System.Exception("rule: bad goal nonterminal: " + goalnt );
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
2,
2,
2,
0,
0,
0,
0,
0,
2,
2,
2,
0,
0,
0,
0,
0,
2,
2,
2,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
10,
10,
10,
0,
0,
0,
0,
0,
2,
2,
2,
0,
0,
0,
0,
0,
2,
2,
2,
0,
0,
0,
0,
0,
2,
2,
2,
0,
0,
0,
0,
0,
2,
2,
2,
0,
0,
0,
0,
0,
2,
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
7,
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
4,
4,
4,
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
5,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
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
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
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
0,
1,
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
1,
0,
0,
0,
0,
0,
1,
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
14,
14,
14,
0,
0,
0,
0,
0,
2,
2,
2,
0,
0,
0,
0,
0,
2,
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
12,
0,
0,
0,
0,
0,
0,
0,
12,
0,
0,
0,
0,
0,
0,
0,
12,
0,
0,
0,
0,
0,
0,
0,
12,
0,
0,
0,
0,
0,
0,
0,
12,
0,
0,
0,
0,
0,
0,
0,
12,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
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
6,
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
1,
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
1,
1,
};
public static int getReWriteGoal(int terminal) { return rewrite_goal[terminal]; }
void init() {
	nts_0 = new int[0];
	nts_1 = new int { inst_NT, inst_NT,  };
	nts_2 = new int { t_NT, tvmi_NT,  };
	nts_3 = new int { tvmi_NT, t_NT,  };
	nts_4 = new int { tvm_NT, immed_NT,  };
	nts_5 = new int { immed_NT, tvm_NT,  };
	nts_6 = new int { t_NT, tvm_NT,  };
	nts_7 = new int { t_NT, tv_NT,  };
	nts_8 = new int { t_NT,  };
	nts_9 = new int { tvmi_NT,  };
	nts_10 = new int { addr_NT,  };
	nts_11 = new int { tv_NT, addr_NT,  };
	nts_12 = new int { immed_NT,  };
	nts_13 = new int { tv_NT,  };
	nts_14 = new int { mem_NT,  };
	nts_15 = new int { tvm_NT,  };
	nts_16 = new int { tv_NT, tvi_NT,  };
	nts_17 = new int { tv_NT, tv_NT, tv_NT,  };
	nts_18 = new int { tvm_NT, tvi_NT,  };
	nts_19 = new int { tv_NT, mem_NT,  };
	nts_20 = new int { tvm_NT, tvm_NT, tvi_NT,  };
	nts_21 = new int { tvm_NT, tvi_NT, tvm_NT,  };
	nts_22 = new int { tv_NT, tv_NT, tvmi_NT,  };
	nts_23 = new int { tv_NT, tvmi_NT, tv_NT,  };
	nts_24 = new int { tvi_NT, tvm_NT,  };
	nts_25 = new int { compare_NT,  };
	nts_26 = new int { t_NT, t_NT,  };
	nts_27 = new int { inst_NT, const_NT,  };
	nts_28 = new int { inst_NT, immed_NT,  };
	nts_29 = new int { arg_NT,  };
	nts_30 = new int { t_NT, arg_NT,  };
	nts_31 = new int { param_NT,  };
	nts_32 = new int { t_NT, param_NT,  };
	nts_33 = new int { inst_NT, tv_NT,  };
	nts_34 = new int { v_NT,  };
	nts_35 = new int { const_NT, tv_NT,  };
	nts_36 = new int { tv_NT, const_NT,  };
	nts_37 = new int { const_NT,  };
	nts_38 = new int { base_NT, index_NT,  };
	nts_39 = new int { index_NT, base_NT,  };
	nts_40 = new int { base_NT,  };
	nts_41 = new int { index_NT,  };
	nts_42 = new int { tv_NT, tv_NT,  };
	nts_43 = new int { t_NT, tvi_NT,  };
	nts = new int[] {
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
		nts_2,	/* 41 */
		nts_3,	/* 42 */
		nts_2,	/* 43 */
		nts_2,	/* 44 */
		nts_3,	/* 45 */
		nts_4,	/* 46 */
		nts_5,	/* 47 */
		nts_6,	/* 48 */
		nts_6,	/* 49 */
		nts_2,	/* 50 */
		nts_3,	/* 51 */
		nts_2,	/* 52 */
		nts_3,	/* 53 */
		nts_2,	/* 54 */
		nts_3,	/* 55 */
		nts_7,	/* 56 */
		nts_7,	/* 57 */
		nts_8,	/* 58 */
		nts_8,	/* 59 */
		nts_9,	/* 60 */
		nts_10,	/* 61 */
		nts_11,	/* 62 */
		nts_12,	/* 63 */
		nts_13,	/* 64 */
		nts_14,	/* 65 */
		nts_12,	/* 66 */
		nts_15,	/* 67 */
		nts_12,	/* 68 */
		nts_15,	/* 69 */
		nts_12,	/* 70 */
		nts_15,	/* 71 */
		nts_12,	/* 72 */
		nts_14,	/* 73 */
		nts_8,	/* 74 */
		nts_12,	/* 75 */
		nts_14,	/* 76 */
		nts_8,	/* 77 */
		nts_12,	/* 78 */
		nts_14,	/* 79 */
		nts_8,	/* 80 */
		nts_15,	/* 81 */
		nts_15,	/* 82 */
		nts_15,	/* 83 */
		nts_16,	/* 84 */
		nts_17,	/* 85 */
		nts_17,	/* 86 */
		nts_18,	/* 87 */
		nts_18,	/* 88 */
		nts_18,	/* 89 */
		nts_19,	/* 90 */
		nts_19,	/* 91 */
		nts_19,	/* 92 */
		nts_9,	/* 93 */
		nts_15,	/* 94 */
		nts_20,	/* 95 */
		nts_21,	/* 96 */
		nts_20,	/* 97 */
		nts_21,	/* 98 */
		nts_20,	/* 99 */
		nts_21,	/* 100 */
		nts_20,	/* 101 */
		nts_21,	/* 102 */
		nts_22,	/* 103 */
		nts_23,	/* 104 */
		nts_20,	/* 105 */
		nts_21,	/* 106 */
		nts_20,	/* 107 */
		nts_21,	/* 108 */
		nts_20,	/* 109 */
		nts_21,	/* 110 */
		nts_20,	/* 111 */
		nts_21,	/* 112 */
		nts_22,	/* 113 */
		nts_23,	/* 114 */
		nts_20,	/* 115 */
		nts_21,	/* 116 */
		nts_20,	/* 117 */
		nts_21,	/* 118 */
		nts_20,	/* 119 */
		nts_21,	/* 120 */
		nts_20,	/* 121 */
		nts_21,	/* 122 */
		nts_22,	/* 123 */
		nts_23,	/* 124 */
		nts_18,	/* 125 */
		nts_24,	/* 126 */
		nts_18,	/* 127 */
		nts_24,	/* 128 */
		nts_18,	/* 129 */
		nts_24,	/* 130 */
		nts_18,	/* 131 */
		nts_24,	/* 132 */
		nts_18,	/* 133 */
		nts_24,	/* 134 */
		nts_18,	/* 135 */
		nts_24,	/* 136 */
		nts_18,	/* 137 */
		nts_24,	/* 138 */
		nts_18,	/* 139 */
		nts_24,	/* 140 */
		nts_18,	/* 141 */
		nts_24,	/* 142 */
		nts_18,	/* 143 */
		nts_24,	/* 144 */
		nts_18,	/* 145 */
		nts_24,	/* 146 */
		nts_18,	/* 147 */
		nts_24,	/* 148 */
		nts_18,	/* 149 */
		nts_24,	/* 150 */
		nts_18,	/* 151 */
		nts_24,	/* 152 */
		nts_18,	/* 153 */
		nts_24,	/* 154 */
		nts_18,	/* 155 */
		nts_24,	/* 156 */
		nts_18,	/* 157 */
		nts_24,	/* 158 */
		nts_18,	/* 159 */
		nts_24,	/* 160 */
		nts_18,	/* 161 */
		nts_24,	/* 162 */
		nts_18,	/* 163 */
		nts_24,	/* 164 */
		nts_18,	/* 165 */
		nts_24,	/* 166 */
		nts_18,	/* 167 */
		nts_24,	/* 168 */
		nts_18,	/* 169 */
		nts_24,	/* 170 */
		nts_18,	/* 171 */
		nts_24,	/* 172 */
		nts_18,	/* 173 */
		nts_24,	/* 174 */
		nts_18,	/* 175 */
		nts_24,	/* 176 */
		nts_18,	/* 177 */
		nts_24,	/* 178 */
		nts_18,	/* 179 */
		nts_24,	/* 180 */
		nts_18,	/* 181 */
		nts_24,	/* 182 */
		nts_18,	/* 183 */
		nts_24,	/* 184 */
		nts_25,	/* 185 */
		nts_15,	/* 186 */
		nts_25,	/* 187 */
		nts_12,	/* 188 */
		nts_12,	/* 189 */
		nts_12,	/* 190 */
		nts_12,	/* 191 */
		nts_12,	/* 192 */
		nts_12,	/* 193 */
		nts_12,	/* 194 */
		nts_12,	/* 195 */
		nts_12,	/* 196 */
		nts_12,	/* 197 */
		nts_12,	/* 198 */
		nts_12,	/* 199 */
		nts_12,	/* 200 */
		nts_12,	/* 201 */
		nts_0,	/* 202 */
		nts_15,	/* 203 */
		nts_15,	/* 204 */
		nts_15,	/* 205 */
		nts_15,	/* 206 */
		nts_15,	/* 207 */
		nts_15,	/* 208 */
		nts_0,	/* 209 */
		nts_8,	/* 210 */
		nts_0,	/* 211 */
		nts_0,	/* 212 */
		nts_0,	/* 213 */
		nts_0,	/* 214 */
		nts_8,	/* 215 */
		nts_8,	/* 216 */
		nts_0,	/* 217 */
		nts_0,	/* 218 */
		nts_0,	/* 219 */
		nts_0,	/* 220 */
		nts_0,	/* 221 */
		nts_0,	/* 222 */
		nts_0,	/* 223 */
		nts_0,	/* 224 */
		nts_0,	/* 225 */
		nts_26,	/* 226 */
		nts_26,	/* 227 */
		nts_0,	/* 228 */
		nts_0,	/* 229 */
		nts_0,	/* 230 */
		nts_0,	/* 231 */
		nts_0,	/* 232 */
		nts_0,	/* 233 */
		nts_27,	/* 234 */
		nts_0,	/* 235 */
		nts_0,	/* 236 */
		nts_0,	/* 237 */
		nts_0,	/* 238 */
		nts_28,	/* 239 */
		nts_10,	/* 240 */
		nts_10,	/* 241 */
		nts_10,	/* 242 */
		nts_0,	/* 243 */
		nts_0,	/* 244 */
		nts_0,	/* 245 */
		nts_0,	/* 246 */
		nts_0,	/* 247 */
		nts_0,	/* 248 */
		nts_0,	/* 249 */
		nts_29,	/* 250 */
		nts_30,	/* 251 */
		nts_30,	/* 252 */
		nts_30,	/* 253 */
		nts_30,	/* 254 */
		nts_30,	/* 255 */
		nts_30,	/* 256 */
		nts_0,	/* 257 */
		nts_8,	/* 258 */
		nts_31,	/* 259 */
		nts_32,	/* 260 */
		nts_32,	/* 261 */
		nts_32,	/* 262 */
		nts_32,	/* 263 */
		nts_32,	/* 264 */
		nts_32,	/* 265 */
		nts_33,	/* 266 */
		nts_33,	/* 267 */
		nts_33,	/* 268 */
		nts_0,	/* 269 */
		nts_0,	/* 270 */
		nts_0,	/* 271 */
		nts_14,	/* 272 */
		nts_13,	/* 273 */
		nts_15,	/* 274 */
		nts_12,	/* 275 */
		nts_8,	/* 276 */
		nts_34,	/* 277 */
		nts_13,	/* 278 */
		nts_12,	/* 279 */
		nts_13,	/* 280 */
		nts_35,	/* 281 */
		nts_36,	/* 282 */
		nts_13,	/* 283 */
		nts_37,	/* 284 */
		nts_36,	/* 285 */
		nts_35,	/* 286 */
		nts_13,	/* 287 */
		nts_38,	/* 288 */
		nts_39,	/* 289 */
		nts_40,	/* 290 */
		nts_41,	/* 291 */
		nts_0,	/* 292 */
		nts_0,	/* 293 */
		nts_0,	/* 294 */
		nts_0,	/* 295 */
		nts_0,	/* 296 */
		nts_0,	/* 297 */
		nts_0,	/* 298 */
		nts_0,	/* 299 */
		nts_0,	/* 300 */
		nts_0,	/* 301 */
		nts_0,	/* 302 */
		nts_0,	/* 303 */
		nts_13,	/* 304 */
		nts_0,	/* 305 */
		nts_0,	/* 306 */
		nts_0,	/* 307 */
		nts_42,	/* 308 */
		nts_42,	/* 309 */
		nts_0,	/* 310 */
		nts_43,	/* 311 */
		nts_43,	/* 312 */
		nts_7,	/* 313 */
		nts_7,	/* 314 */
		nts_0,	/* 315 */
		nts_26,	/* 316 */
		nts_8,	/* 317 */
		nts_8,	/* 318 */
		nts_0,	/* 319 */
		nts_8,	/* 320 */
		nts_0,	/* 321 */
		nts_0,	/* 322 */
		nts_8,	/* 323 */
		nts_0,	/* 324 */
		nts_0,	/* 325 */
		nts_0,	/* 326 */
		nts_0,	/* 327 */
	};

	decode_inst = {
		0,
		1,
		2,
		62,
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
		122,
		123,
		124,
		186,
		187,
		188,
		189,
		190,
		191,
		192,
		193,
		194,
		195,
		196,
		197,
		198,
		199,
		200,
		201,
		202,
		203,
		204,
		205,
		206,
		207,
		208,
		209,
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
		225,
		226,
		227,
		228,
		250,
		259,
		280,
		295,
		296,
		297,
		298,
		299,
		300,
		301,
		302,
		303,
		304,
		305,
		306,
		307,
		308,
		309,
		310,
		316,
		317,
		318,
		319,
		320,
		321,
		322,
		323,
		324,
		325,
		326,
		327,
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
		43,
		44,
		45,
		46,
		47,
		48,
		49,
		50,
		51,
		52,
		53,
		54,
		55,
		56,
		57,
		58,
		59,
		60,
		61,
		74,
		77,
		80,
		185,
		210,
		243,
		244,
		245,
		246,
		247,
		248,
		311,
		312,
		313,
		314,
		315,
	};

	decode_tvmi = {
		0,
		274,
		275,
	};

	decode_tvm = {
		0,
		81,
		82,
		83,
		272,
		273,
	};

	decode_immed = {
		0,
		63,
		66,
		68,
		70,
		72,
		75,
		78,
		235,
		236,
		237,
		238,
		239,
	};

	decode_tv = {
		0,
		64,
		67,
		69,
		71,
		84,
		266,
		267,
		268,
		276,
		277,
	};

	decode_addr = {
		0,
		288,
		289,
		290,
		291,
		292,
		293,
		294,
	};

	decode_mem = {
		0,
		65,
		73,
		76,
		79,
		211,
		213,
		229,
		240,
		241,
		242,
	};

	decode_tvi = {
		0,
		278,
		279,
	};

	decode_compare = {
		0,
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
		139,
		140,
		141,
		142,
		143,
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
		158,
		159,
		160,
		161,
		162,
		163,
		164,
		165,
		166,
		167,
		168,
		169,
		170,
		171,
		172,
		173,
		174,
		175,
		176,
		177,
		178,
		179,
		180,
		181,
		182,
		183,
		184,
	};

	decode_const = {
		0,
		212,
		214,
		230,
		231,
		232,
		233,
		234,
	};

	decode_arg = {
		0,
		249,
		251,
		252,
		253,
		254,
		255,
		256,
	};

	decode_param = {
		0,
		257,
		258,
		260,
		261,
		262,
		263,
		264,
		265,
	};

	decode_v = {
		0,
		269,
		270,
		271,
	};

	decode_base = {
		0,
		281,
		282,
		283,
		284,
	};

	decode_index = {
		0,
		285,
		286,
		287,
	};

	nts_name = new System.String {
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
		"arg",	/* arg*/
		"param",	/* param*/
		"v",	/* v*/
		"base",	/* base*/
		"index",	/* index*/
	};
	result = new ITreeFactory {
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

	new ITreeFactory239(),

	new ITreeFactory240(),

	new ITreeFactory241(),

	new ITreeFactory242(),

	new ITreeFactory243(),

	new ITreeFactory244(),

	new ITreeFactory245(),

	new ITreeFactory246(),

	new ITreeFactory247(),

	new ITreeFactory248(),

	new ITreeFactory249(),

	new ITreeFactory250(),

	new ITreeFactory251(),

	new ITreeFactory252(),

	new ITreeFactory253(),

	new ITreeFactory254(),

	new ITreeFactory255(),

	new ITreeFactory256(),

	new ITreeFactory257(),

	new ITreeFactory258(),

	new ITreeFactory259(),

	new ITreeFactory260(),

	new ITreeFactory261(),

	new ITreeFactory262(),

	new ITreeFactory263(),

	new ITreeFactory264(),

	new ITreeFactory265(),

	new ITreeFactory266(),

	new ITreeFactory267(),

	new ITreeFactory268(),

	new ITreeFactory269(),

	new ITreeFactory270(),

	new ITreeFactory271(),

	new ITreeFactory272(),

	new ITreeFactory273(),

	new ITreeFactory274(),

	new ITreeFactory275(),

	new ITreeFactory276(),

	new ITreeFactory277(),

	new ITreeFactory278(),

	new ITreeFactory279(),

	new ITreeFactory280(),

	new ITreeFactory281(),

	new ITreeFactory282(),

	new ITreeFactory283(),

	new ITreeFactory284(),

	new ITreeFactory285(),

	new ITreeFactory286(),

	new ITreeFactory287(),

	new ITreeFactory288(),

	new ITreeFactory289(),

	new ITreeFactory290(),

	new ITreeFactory291(),

	new ITreeFactory292(),

	new ITreeFactory293(),

	new ITreeFactory294(),

	new ITreeFactory295(),

	new ITreeFactory296(),

	new ITreeFactory297(),

	new ITreeFactory298(),

	new ITreeFactory299(),

	new ITreeFactory300(),

	new ITreeFactory301(),

	new ITreeFactory302(),

	new ITreeFactory303(),

	new ITreeFactory304(),

	new ITreeFactory305(),

	new ITreeFactory306(),

	new ITreeFactory307(),

	new ITreeFactory308(),

	new ITreeFactory309(),

	new ITreeFactory310(),

	new ITreeFactory311(),

	new ITreeFactory312(),

	new ITreeFactory313(),

	new ITreeFactory314(),

	new ITreeFactory315(),

	new ITreeFactory316(),

	new ITreeFactory317(),

	new ITreeFactory318(),

	new ITreeFactory319(),

	new ITreeFactory320(),

	new ITreeFactory321(),

	new ITreeFactory322(),

	new ITreeFactory323(),

	new ITreeFactory324(),

	new ITreeFactory325(),

	new ITreeFactory326(),

	new ITreeFactory327(),
	};
}
void closure_t(ITree a, int c) {
	State p = a.getReWriteState();
	// match t -> tv 276->tv ?
	if(c + 0 < p.cost[tv_NT]) {
		p.cost[tv_NT] = c + 0;
		p.rule[tv_NT] = 9;
		closure_tv(a, c + 0);
	}
}

void closure_tvmi(ITree a, int c) {
	State p = a.getReWriteState();
	// match tvmi -> t 60->t ?
	if(c + 5 < p.cost[t_NT]) {
		p.cost[t_NT] = c + 5;
		p.rule[t_NT] = 58;
		closure_t(a, c + 5);
	}
}

void closure_tvm(ITree a, int c) {
	State p = a.getReWriteState();
	// match tvm -> tvmi 274->tvmi ?
	if(c + 0 < p.cost[tvmi_NT]) {
		p.cost[tvmi_NT] = c + 0;
		p.rule[tvmi_NT] = 1;
		closure_tvmi(a, c + 0);
	}
}

void closure_immed(ITree a, int c) {
	State p = a.getReWriteState();
	// match immed -> tvi 279->tvi ?
	if(c + 0 < p.cost[tvi_NT]) {
		p.cost[tvi_NT] = c + 0;
		p.rule[tvi_NT] = 2;
	}
	// match immed -> tvmi 275->tvmi ?
	if(c + 0 < p.cost[tvmi_NT]) {
		p.cost[tvmi_NT] = c + 0;
		p.rule[tvmi_NT] = 2;
		closure_tvmi(a, c + 0);
	}
}

void closure_tv(ITree a, int c) {
	State p = a.getReWriteState();
	// match tv -> index 287->index ?
	if(c + 1 < p.cost[index_NT]) {
		p.cost[index_NT] = c + 1;
		p.rule[index_NT] = 3;
		closure_index(a, c + 1);
	}
	// match tv -> base 283->base ?
	if(c + 0 < p.cost[base_NT]) {
		p.cost[base_NT] = c + 0;
		p.rule[base_NT] = 3;
		closure_base(a, c + 0);
	}
	// match tv -> inst 280->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 84;
	}
	// match tv -> tvi 278->tvi ?
	if(c + 0 < p.cost[tvi_NT]) {
		p.cost[tvi_NT] = c + 0;
		p.rule[tvi_NT] = 1;
	}
	// match tv -> tvm 273->tvm ?
	if(c + 0 < p.cost[tvm_NT]) {
		p.cost[tvm_NT] = c + 0;
		p.rule[tvm_NT] = 5;
		closure_tvm(a, c + 0);
	}
}

void closure_addr(ITree a, int c) {
	State p = a.getReWriteState();
	// match addr -> t 61->t ?
	if(c + 10 < p.cost[t_NT]) {
		p.cost[t_NT] = c + 10;
		p.rule[t_NT] = 59;
		closure_t(a, c + 10);
	}
}

void closure_mem(ITree a, int c) {
	State p = a.getReWriteState();
	// match mem -> tvm 272->tvm ?
	if(c + 0 < p.cost[tvm_NT]) {
		p.cost[tvm_NT] = c + 0;
		p.rule[tvm_NT] = 4;
		closure_tvm(a, c + 0);
	}
}

void closure_compare(ITree a, int c) {
	State p = a.getReWriteState();
	// match compare -> t 185->t ?
	if(c + 20 < p.cost[t_NT]) {
		p.cost[t_NT] = c + 20;
		p.rule[t_NT] = 63;
		closure_t(a, c + 20);
	}
}

void closure_const(ITree a, int c) {
	State p = a.getReWriteState();
	// match const -> base 284->base ?
	if(c + 0 < p.cost[base_NT]) {
		p.cost[base_NT] = c + 0;
		p.rule[base_NT] = 4;
		closure_base(a, c + 0);
	}
}

void closure_arg(ITree a, int c) {
	State p = a.getReWriteState();
	// match arg -> inst 250->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 82;
	}
}

void closure_param(ITree a, int c) {
	State p = a.getReWriteState();
	// match param -> inst 259->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 83;
	}
}

void closure_v(ITree a, int c) {
	State p = a.getReWriteState();
	// match v -> tv 277->tv ?
	if(c + 0 < p.cost[tv_NT]) {
		p.cost[tv_NT] = c + 0;
		p.rule[tv_NT] = 10;
		closure_tv(a, c + 0);
	}
}

void closure_base(ITree a, int c) {
	State p = a.getReWriteState();
	// match base -> addr 290->addr ?
	if(c + 0 < p.cost[addr_NT]) {
		p.cost[addr_NT] = c + 0;
		p.rule[addr_NT] = 3;
		closure_addr(a, c + 0);
	}
}

void closure_index(ITree a, int c) {
	State p = a.getReWriteState();
	// match index -> addr 291->addr ?
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
		/* [INDIRECT_1 addr] -> mem 242 */		c = a.getLeft().getReWriteState().cost[addr_NT] + 
10;
		// match [INDIRECT_1 addr] -> mem 242->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 10;
			closure_mem(a, c + 0);
		}
		break;
		case 10: /* INDIRECT_4 */
		label(a.getLeft());
		/* [INDIRECT_4 addr] -> mem 241 */		c = a.getLeft().getReWriteState().cost[addr_NT] + 
10;
		// match [INDIRECT_4 addr] -> mem 241->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 9;
			closure_mem(a, c + 0);
		}
		break;
		case 11: /* INDIRECT_8 */
		label(a.getLeft());
		if(/* [INDIRECT_8 GLOBAL_8] -> mem 229 arity 1 */
			a.getLeft().getOperator() == 331 /* BB GLOBAL_8*/
		) {
			c = 0;
			// match [INDIRECT_8 GLOBAL_8] -> mem 229->mem ?
			if(c + 0 < p.cost[mem_NT]) {
				p.cost[mem_NT] = c + 0;
				p.rule[mem_NT] = 7;
				closure_mem(a, c + 0);
			}
		}
		/* [INDIRECT_8 addr] -> mem 240 */		c = a.getLeft().getReWriteState().cost[addr_NT] + 
10;
		// match [INDIRECT_8 addr] -> mem 240->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 8;
			closure_mem(a, c + 0);
		}
		break;
		case 17: /* LEA_1 */
		break;
		case 18: /* LEA_4 */
		break;
		case 19: /* LEA_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [LEA_8 tv addr] -> inst 62 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[addr_NT] + 
10;
		// match [LEA_8 tv addr] -> inst 62->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 3;
		}
		break;
		case 25: /* ADD_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD_1 t tvmi] -> t 41 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [ADD_1 t tvmi] -> t 41->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 39;
			closure_t(a, c + 0);
		}
		/* [ADD_1 tvmi t] -> t 42 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [ADD_1 tvmi t] -> t 42->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 40;
			closure_t(a, c + 0);
		}
		break;
		case 26: /* ADD_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD_4 t tvmi] -> t 22 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [ADD_4 t tvmi] -> t 22->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 20;
			closure_t(a, c + 0);
		}
		/* [ADD_4 tvmi t] -> t 23 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [ADD_4 tvmi t] -> t 23->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 21;
			closure_t(a, c + 0);
		}
		break;
		case 27: /* ADD_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD_8 t tvmi] -> t 3 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [ADD_8 t tvmi] -> t 3->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 1;
			closure_t(a, c + 0);
		}
		/* [ADD_8 tvmi t] -> t 4 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [ADD_8 tvmi t] -> t 4->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 2;
			closure_t(a, c + 0);
		}
		/* [ADD_8 const tv] -> base 281 */
		c = a.getLeft().getReWriteState().cost[const_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
0;
		// match [ADD_8 const tv] -> base 281->base ?
		if(c + 0 < p.cost[base_NT]) {
			p.cost[base_NT] = c + 0;
			p.rule[base_NT] = 1;
			closure_base(a, c + 0);
		}
		/* [ADD_8 tv const] -> base 282 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[const_NT] + 
0;
		// match [ADD_8 tv const] -> base 282->base ?
		if(c + 0 < p.cost[base_NT]) {
			p.cost[base_NT] = c + 0;
			p.rule[base_NT] = 2;
			closure_base(a, c + 0);
		}
		/* [ADD_8 base index] -> addr 288 */
		c = a.getLeft().getReWriteState().cost[base_NT] + 
a.getRight().getReWriteState().cost[index_NT] + 
0;
		// match [ADD_8 base index] -> addr 288->addr ?
		if(c + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = c + 0;
			p.rule[addr_NT] = 1;
			closure_addr(a, c + 0);
		}
		/* [ADD_8 index base] -> addr 289 */
		c = a.getLeft().getReWriteState().cost[index_NT] + 
a.getRight().getReWriteState().cost[base_NT] + 
0;
		// match [ADD_8 index base] -> addr 289->addr ?
		if(c + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = c + 0;
			p.rule[addr_NT] = 2;
			closure_addr(a, c + 0);
		}
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
		/* [SUB_1 t tvmi] -> t 43 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [SUB_1 t tvmi] -> t 43->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 41;
			closure_t(a, c + 0);
		}
		break;
		case 34: /* SUB_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SUB_4 t tvmi] -> t 24 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [SUB_4 t tvmi] -> t 24->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 22;
			closure_t(a, c + 0);
		}
		break;
		case 35: /* SUB_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SUB_8 t tvmi] -> t 5 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [SUB_8 t tvmi] -> t 5->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 3;
			closure_t(a, c + 0);
		}
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
		/* [MUL_1 t tvmi] -> t 44 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [MUL_1 t tvmi] -> t 44->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 42;
			closure_t(a, c + 0);
		}
		/* [MUL_1 tvmi t] -> t 45 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [MUL_1 tvmi t] -> t 45->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 43;
			closure_t(a, c + 0);
		}
		/* [MUL_1 tvm immed] -> t 46 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
10;
		// match [MUL_1 tvm immed] -> t 46->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 44;
			closure_t(a, c + 0);
		}
		/* [MUL_1 immed tvm] -> t 47 */
		c = a.getLeft().getReWriteState().cost[immed_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MUL_1 immed tvm] -> t 47->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 45;
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
		/* [MUL_4 t tvmi] -> t 25 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [MUL_4 t tvmi] -> t 25->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 23;
			closure_t(a, c + 0);
		}
		/* [MUL_4 tvmi t] -> t 26 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [MUL_4 tvmi t] -> t 26->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 24;
			closure_t(a, c + 0);
		}
		/* [MUL_4 tvm immed] -> t 27 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
10;
		// match [MUL_4 tvm immed] -> t 27->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 25;
			closure_t(a, c + 0);
		}
		/* [MUL_4 immed tvm] -> t 28 */
		c = a.getLeft().getReWriteState().cost[immed_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MUL_4 immed tvm] -> t 28->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 26;
			closure_t(a, c + 0);
		}
		break;
		case 51: /* MUL_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [MUL_8 t tvmi] -> t 6 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [MUL_8 t tvmi] -> t 6->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 4;
			closure_t(a, c + 0);
		}
		/* [MUL_8 tvmi t] -> t 7 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [MUL_8 tvmi t] -> t 7->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 5;
			closure_t(a, c + 0);
		}
		/* [MUL_8 tvm immed] -> t 8 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
10;
		// match [MUL_8 tvm immed] -> t 8->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 6;
			closure_t(a, c + 0);
		}
		/* [MUL_8 immed tvm] -> t 9 */
		c = a.getLeft().getReWriteState().cost[immed_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MUL_8 immed tvm] -> t 9->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 7;
			closure_t(a, c + 0);
		}
		/* [MUL_8 tv const] -> index 285 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[const_NT] + 
( a.scaleRight(1,32768) );
		// match [MUL_8 tv const] -> index 285->index ?
		if(c + 0 < p.cost[index_NT]) {
			p.cost[index_NT] = c + 0;
			p.rule[index_NT] = 1;
			closure_index(a, c + 0);
		}
		/* [MUL_8 const tv] -> index 286 */
		c = a.getLeft().getReWriteState().cost[const_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
( a.scaleLeft(1,32768) );
		// match [MUL_8 const tv] -> index 286->index ?
		if(c + 0 < p.cost[index_NT]) {
			p.cost[index_NT] = c + 0;
			p.rule[index_NT] = 2;
			closure_index(a, c + 0);
		}
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
		/* [DIV_1 t tvm] -> t 48 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [DIV_1 t tvm] -> t 48->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 46;
			closure_t(a, c + 0);
		}
		break;
		case 58: /* DIV_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [DIV_4 t tvm] -> t 29 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [DIV_4 t tvm] -> t 29->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 27;
			closure_t(a, c + 0);
		}
		break;
		case 59: /* DIV_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [DIV_8 t tvm] -> t 10 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [DIV_8 t tvm] -> t 10->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 8;
			closure_t(a, c + 0);
		}
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
		/* [MOD_1 t tvm] -> t 49 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MOD_1 t tvm] -> t 49->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 47;
			closure_t(a, c + 0);
		}
		break;
		case 74: /* MOD_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [MOD_4 t tvm] -> t 30 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MOD_4 t tvm] -> t 30->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 28;
			closure_t(a, c + 0);
		}
		break;
		case 75: /* MOD_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [MOD_8 t tvm] -> t 11 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
10;
		// match [MOD_8 t tvm] -> t 11->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 9;
			closure_t(a, c + 0);
		}
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
		/* [SHL_1 t tv] -> t 56 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHL_1 t tv] -> t 56->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 54;
			closure_t(a, c + 0);
		}
		break;
		case 82: /* SHL_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHL_4 t tv] -> t 37 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHL_4 t tv] -> t 37->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 35;
			closure_t(a, c + 0);
		}
		break;
		case 83: /* SHL_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHL_8 t tv] -> t 18 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHL_8 t tv] -> t 18->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 16;
			closure_t(a, c + 0);
		}
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
		/* [SHAR_1 t tv] -> t 57 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHAR_1 t tv] -> t 57->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 55;
			closure_t(a, c + 0);
		}
		break;
		case 90: /* SHAR_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHAR_4 t tv] -> t 38 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHAR_4 t tv] -> t 38->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 36;
			closure_t(a, c + 0);
		}
		break;
		case 91: /* SHAR_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHAR_8 t tv] -> t 19 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [SHAR_8 t tv] -> t 19->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 17;
			closure_t(a, c + 0);
		}
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
		/* [EQ_1 tvm tvi] -> compare 165 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [EQ_1 tvm tvi] -> compare 165->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 41;
			closure_compare(a, c + 0);
		}
		/* [EQ_1 tvi tvm] -> compare 166 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [EQ_1 tvi tvm] -> compare 166->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 42;
			closure_compare(a, c + 0);
		}
		break;
		case 98: /* EQ_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [EQ_4 tvm tvi] -> compare 145 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [EQ_4 tvm tvi] -> compare 145->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 21;
			closure_compare(a, c + 0);
		}
		/* [EQ_4 tvi tvm] -> compare 146 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [EQ_4 tvi tvm] -> compare 146->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 22;
			closure_compare(a, c + 0);
		}
		break;
		case 99: /* EQ_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [EQ_8 tvm tvi] -> compare 125 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [EQ_8 tvm tvi] -> compare 125->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 1;
			closure_compare(a, c + 0);
		}
		/* [EQ_8 tvi tvm] -> compare 126 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [EQ_8 tvi tvm] -> compare 126->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 2;
			closure_compare(a, c + 0);
		}
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
		/* [NE_1 tvm tvi] -> compare 167 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [NE_1 tvm tvi] -> compare 167->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 43;
			closure_compare(a, c + 0);
		}
		/* [NE_1 tvi tvm] -> compare 168 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [NE_1 tvi tvm] -> compare 168->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 44;
			closure_compare(a, c + 0);
		}
		break;
		case 106: /* NE_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [NE_4 tvm tvi] -> compare 147 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [NE_4 tvm tvi] -> compare 147->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 23;
			closure_compare(a, c + 0);
		}
		/* [NE_4 tvi tvm] -> compare 148 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [NE_4 tvi tvm] -> compare 148->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 24;
			closure_compare(a, c + 0);
		}
		break;
		case 107: /* NE_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [NE_8 tvm tvi] -> compare 127 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [NE_8 tvm tvi] -> compare 127->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 3;
			closure_compare(a, c + 0);
		}
		/* [NE_8 tvi tvm] -> compare 128 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [NE_8 tvi tvm] -> compare 128->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 4;
			closure_compare(a, c + 0);
		}
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
		/* [GT_1 tvm tvi] -> compare 169 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GT_1 tvm tvi] -> compare 169->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 45;
			closure_compare(a, c + 0);
		}
		/* [GT_1 tvi tvm] -> compare 170 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GT_1 tvi tvm] -> compare 170->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 46;
			closure_compare(a, c + 0);
		}
		break;
		case 114: /* GT_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GT_4 tvm tvi] -> compare 149 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GT_4 tvm tvi] -> compare 149->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 25;
			closure_compare(a, c + 0);
		}
		/* [GT_4 tvi tvm] -> compare 150 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GT_4 tvi tvm] -> compare 150->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 26;
			closure_compare(a, c + 0);
		}
		break;
		case 115: /* GT_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [GT_8 tvm tvi] -> compare 129 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GT_8 tvm tvi] -> compare 129->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 5;
			closure_compare(a, c + 0);
		}
		/* [GT_8 tvi tvm] -> compare 130 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GT_8 tvi tvm] -> compare 130->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 6;
			closure_compare(a, c + 0);
		}
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
		/* [LT_1 tvm tvi] -> compare 171 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LT_1 tvm tvi] -> compare 171->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 47;
			closure_compare(a, c + 0);
		}
		/* [LT_1 tvi tvm] -> compare 172 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LT_1 tvi tvm] -> compare 172->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 48;
			closure_compare(a, c + 0);
		}
		break;
		case 122: /* LT_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LT_4 tvm tvi] -> compare 151 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LT_4 tvm tvi] -> compare 151->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 27;
			closure_compare(a, c + 0);
		}
		/* [LT_4 tvi tvm] -> compare 152 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LT_4 tvi tvm] -> compare 152->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 28;
			closure_compare(a, c + 0);
		}
		break;
		case 123: /* LT_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [LT_8 tvm tvi] -> compare 131 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LT_8 tvm tvi] -> compare 131->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 7;
			closure_compare(a, c + 0);
		}
		/* [LT_8 tvi tvm] -> compare 132 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LT_8 tvi tvm] -> compare 132->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 8;
			closure_compare(a, c + 0);
		}
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
		/* [GE_1 tvm tvi] -> compare 173 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GE_1 tvm tvi] -> compare 173->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 49;
			closure_compare(a, c + 0);
		}
		/* [GE_1 tvi tvm] -> compare 174 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GE_1 tvi tvm] -> compare 174->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 50;
			closure_compare(a, c + 0);
		}
		break;
		case 130: /* GE_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GE_4 tvm tvi] -> compare 153 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GE_4 tvm tvi] -> compare 153->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 29;
			closure_compare(a, c + 0);
		}
		/* [GE_4 tvi tvm] -> compare 154 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GE_4 tvi tvm] -> compare 154->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 30;
			closure_compare(a, c + 0);
		}
		break;
		case 131: /* GE_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [GE_8 tvm tvi] -> compare 133 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GE_8 tvm tvi] -> compare 133->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 9;
			closure_compare(a, c + 0);
		}
		/* [GE_8 tvi tvm] -> compare 134 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GE_8 tvi tvm] -> compare 134->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 10;
			closure_compare(a, c + 0);
		}
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
		/* [LE_1 tvm tvi] -> compare 175 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LE_1 tvm tvi] -> compare 175->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 51;
			closure_compare(a, c + 0);
		}
		/* [LE_1 tvi tvm] -> compare 176 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LE_1 tvi tvm] -> compare 176->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 52;
			closure_compare(a, c + 0);
		}
		break;
		case 138: /* LE_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LE_4 tvm tvi] -> compare 155 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LE_4 tvm tvi] -> compare 155->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 31;
			closure_compare(a, c + 0);
		}
		/* [LE_4 tvi tvm] -> compare 156 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LE_4 tvi tvm] -> compare 156->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 32;
			closure_compare(a, c + 0);
		}
		break;
		case 139: /* LE_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [LE_8 tvm tvi] -> compare 135 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LE_8 tvm tvi] -> compare 135->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 11;
			closure_compare(a, c + 0);
		}
		/* [LE_8 tvi tvm] -> compare 136 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LE_8 tvi tvm] -> compare 136->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 12;
			closure_compare(a, c + 0);
		}
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
		/* [GTU_1 tvm tvi] -> compare 177 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GTU_1 tvm tvi] -> compare 177->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 53;
			closure_compare(a, c + 0);
		}
		/* [GTU_1 tvi tvm] -> compare 178 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GTU_1 tvi tvm] -> compare 178->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 54;
			closure_compare(a, c + 0);
		}
		break;
		case 146: /* GTU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GTU_4 tvm tvi] -> compare 157 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GTU_4 tvm tvi] -> compare 157->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 33;
			closure_compare(a, c + 0);
		}
		/* [GTU_4 tvi tvm] -> compare 158 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GTU_4 tvi tvm] -> compare 158->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 34;
			closure_compare(a, c + 0);
		}
		break;
		case 147: /* GTU_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [GTU_8 tvm tvi] -> compare 137 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GTU_8 tvm tvi] -> compare 137->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 13;
			closure_compare(a, c + 0);
		}
		/* [GTU_8 tvi tvm] -> compare 138 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GTU_8 tvi tvm] -> compare 138->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 14;
			closure_compare(a, c + 0);
		}
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
		/* [LTU_1 tvm tvi] -> compare 179 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LTU_1 tvm tvi] -> compare 179->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 55;
			closure_compare(a, c + 0);
		}
		/* [LTU_1 tvi tvm] -> compare 180 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LTU_1 tvi tvm] -> compare 180->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 56;
			closure_compare(a, c + 0);
		}
		break;
		case 154: /* LTU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LTU_4 tvm tvi] -> compare 159 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LTU_4 tvm tvi] -> compare 159->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 35;
			closure_compare(a, c + 0);
		}
		/* [LTU_4 tvi tvm] -> compare 160 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LTU_4 tvi tvm] -> compare 160->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 36;
			closure_compare(a, c + 0);
		}
		break;
		case 155: /* LTU_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [LTU_8 tvm tvi] -> compare 139 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LTU_8 tvm tvi] -> compare 139->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 15;
			closure_compare(a, c + 0);
		}
		/* [LTU_8 tvi tvm] -> compare 140 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LTU_8 tvi tvm] -> compare 140->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 16;
			closure_compare(a, c + 0);
		}
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
		/* [GEU_1 tvm tvi] -> compare 181 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GEU_1 tvm tvi] -> compare 181->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 57;
			closure_compare(a, c + 0);
		}
		/* [GEU_1 tvi tvm] -> compare 182 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GEU_1 tvi tvm] -> compare 182->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 58;
			closure_compare(a, c + 0);
		}
		break;
		case 162: /* GEU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [GEU_4 tvm tvi] -> compare 161 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GEU_4 tvm tvi] -> compare 161->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 37;
			closure_compare(a, c + 0);
		}
		/* [GEU_4 tvi tvm] -> compare 162 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GEU_4 tvi tvm] -> compare 162->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 38;
			closure_compare(a, c + 0);
		}
		break;
		case 163: /* GEU_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [GEU_8 tvm tvi] -> compare 141 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [GEU_8 tvm tvi] -> compare 141->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 17;
			closure_compare(a, c + 0);
		}
		/* [GEU_8 tvi tvm] -> compare 142 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [GEU_8 tvi tvm] -> compare 142->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 18;
			closure_compare(a, c + 0);
		}
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
		/* [LEU_1 tvm tvi] -> compare 183 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LEU_1 tvm tvi] -> compare 183->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 59;
			closure_compare(a, c + 0);
		}
		/* [LEU_1 tvi tvm] -> compare 184 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LEU_1 tvi tvm] -> compare 184->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 60;
			closure_compare(a, c + 0);
		}
		break;
		case 170: /* LEU_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [LEU_4 tvm tvi] -> compare 163 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LEU_4 tvm tvi] -> compare 163->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 39;
			closure_compare(a, c + 0);
		}
		/* [LEU_4 tvi tvm] -> compare 164 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LEU_4 tvi tvm] -> compare 164->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 40;
			closure_compare(a, c + 0);
		}
		break;
		case 171: /* LEU_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [LEU_8 tvm tvi] -> compare 143 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
20;
		// match [LEU_8 tvm tvi] -> compare 143->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 19;
			closure_compare(a, c + 0);
		}
		/* [LEU_8 tvi tvm] -> compare 144 */
		c = a.getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getReWriteState().cost[tvm_NT] + 
20;
		// match [LEU_8 tvi tvm] -> compare 144->compare ?
		if(c + 0 < p.cost[compare_NT]) {
			p.cost[compare_NT] = c + 0;
			p.rule[compare_NT] = 20;
			closure_compare(a, c + 0);
		}
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
		/* [AND_1 t tvmi] -> t 50 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [AND_1 t tvmi] -> t 50->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 48;
			closure_t(a, c + 0);
		}
		/* [AND_1 tvmi t] -> t 51 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [AND_1 tvmi t] -> t 51->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 49;
			closure_t(a, c + 0);
		}
		break;
		case 178: /* AND_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [AND_4 t tvmi] -> t 31 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [AND_4 t tvmi] -> t 31->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 29;
			closure_t(a, c + 0);
		}
		/* [AND_4 tvmi t] -> t 32 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [AND_4 tvmi t] -> t 32->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 30;
			closure_t(a, c + 0);
		}
		break;
		case 179: /* AND_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [AND_8 t tvmi] -> t 12 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [AND_8 t tvmi] -> t 12->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 10;
			closure_t(a, c + 0);
		}
		/* [AND_8 tvmi t] -> t 13 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [AND_8 tvmi t] -> t 13->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 11;
			closure_t(a, c + 0);
		}
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
		/* [OR_1 t tvmi] -> t 52 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [OR_1 t tvmi] -> t 52->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 50;
			closure_t(a, c + 0);
		}
		/* [OR_1 tvmi t] -> t 53 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [OR_1 tvmi t] -> t 53->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 51;
			closure_t(a, c + 0);
		}
		break;
		case 186: /* OR_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [OR_4 t tvmi] -> t 33 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [OR_4 t tvmi] -> t 33->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 31;
			closure_t(a, c + 0);
		}
		/* [OR_4 tvmi t] -> t 34 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [OR_4 tvmi t] -> t 34->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 32;
			closure_t(a, c + 0);
		}
		break;
		case 187: /* OR_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [OR_8 t tvmi] -> t 14 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [OR_8 t tvmi] -> t 14->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 12;
			closure_t(a, c + 0);
		}
		/* [OR_8 tvmi t] -> t 15 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [OR_8 tvmi t] -> t 15->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 13;
			closure_t(a, c + 0);
		}
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
		/* [XOR_1 t tvmi] -> t 54 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [XOR_1 t tvmi] -> t 54->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 52;
			closure_t(a, c + 0);
		}
		/* [XOR_1 tvmi t] -> t 55 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [XOR_1 tvmi t] -> t 55->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 53;
			closure_t(a, c + 0);
		}
		break;
		case 194: /* XOR_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [XOR_4 t tvmi] -> t 35 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [XOR_4 t tvmi] -> t 35->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 33;
			closure_t(a, c + 0);
		}
		/* [XOR_4 tvmi t] -> t 36 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [XOR_4 tvmi t] -> t 36->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 34;
			closure_t(a, c + 0);
		}
		break;
		case 195: /* XOR_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [XOR_8 t tvmi] -> t 16 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvmi_NT] + 
10;
		// match [XOR_8 t tvmi] -> t 16->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 14;
			closure_t(a, c + 0);
		}
		/* [XOR_8 tvmi t] -> t 17 */
		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [XOR_8 tvmi t] -> t 17->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 15;
			closure_t(a, c + 0);
		}
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
		/* [NOT_1 t] -> t 59 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NOT_1 t] -> t 59->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 57;
			closure_t(a, c + 0);
		}
		break;
		case 202: /* NOT_4 */
		label(a.getLeft());
		/* [NOT_4 t] -> t 40 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NOT_4 t] -> t 40->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 38;
			closure_t(a, c + 0);
		}
		break;
		case 203: /* NOT_8 */
		label(a.getLeft());
		/* [NOT_8 t] -> t 21 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NOT_8 t] -> t 21->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 19;
			closure_t(a, c + 0);
		}
		break;
		case 205: /* NOT2_1 */
		break;
		case 206: /* NOT2_4 */
		break;
		case 207: /* NOT2_8 */
		break;
		case 209: /* NEG_1 */
		label(a.getLeft());
		/* [NEG_1 t] -> t 58 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NEG_1 t] -> t 58->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 56;
			closure_t(a, c + 0);
		}
		break;
		case 210: /* NEG_4 */
		label(a.getLeft());
		/* [NEG_4 t] -> t 39 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NEG_4 t] -> t 39->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 37;
			closure_t(a, c + 0);
		}
		break;
		case 211: /* NEG_8 */
		label(a.getLeft());
		/* [NEG_8 t] -> t 20 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [NEG_8 t] -> t 20->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 18;
			closure_t(a, c + 0);
		}
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
		//COMMENT_0 -> inst 1->COMMENT_0 ?
		/* COMMENT_0 -> inst 1 arity 0 */
		// match COMMENT_0 -> inst 1->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 1;
		}
		//COMMENT_0 -> arg 249->COMMENT_0 ?
		/* COMMENT_0 -> arg 249 arity 0 */
		// match COMMENT_0 -> arg 249->arg ?
		if(10 + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = 10 + 0;
			p.rule[arg_NT] = 1;
			closure_arg(a, 10 + 0);
		}
		//COMMENT_0 -> param 257->COMMENT_0 ?
		/* COMMENT_0 -> param 257 arity 0 */
		// match COMMENT_0 -> param 257->param ?
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
		if(/* [OBJ_EQ_0 [PAIR_8 tv tv] tv] -> inst 85 arity 2 */
			a.getLeft().getOperator() == 611 /* BB PAIR_8*/
		) {
			c = a.getLeft().getLeft().getReWriteState().cost[tv_NT] + 
a.getLeft().getRight().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
20;
			// match [OBJ_EQ_0 [PAIR_8 tv tv] tv] -> inst 85->inst ?
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
		if(/* [OBJ_NE_0 [PAIR_8 tv tv] tv] -> inst 86 arity 2 */
			a.getLeft().getOperator() == 611 /* BB PAIR_8*/
		) {
			c = a.getLeft().getLeft().getReWriteState().cost[tv_NT] + 
a.getLeft().getRight().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
20;
			// match [OBJ_NE_0 [PAIR_8 tv tv] tv] -> inst 86->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 5;
			}
}
		break;
		case 268: /* OBJ_NE2_0 */
		break;
		case 272: /* BOUNDS_L_0 */
		//BOUNDS_L_0 -> inst 310->BOUNDS_L_0 ?
		/* BOUNDS_L_0 -> inst 310 arity 0 */
		// match BOUNDS_L_0 -> inst 310->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 100;
		}
		break;
		case 280: /* BOUNDS_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [BOUNDS_0 tv tv] -> inst 308 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [BOUNDS_0 tv tv] -> inst 308->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 98;
		}
		break;
		case 288: /* BOUNDS_R_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [BOUNDS_R_0 tv tv] -> inst 309 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [BOUNDS_R_0 tv tv] -> inst 309->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 99;
		}
		break;
		case 297: /* LOCAL_1 */
		//LOCAL_1 -> addr 294->LOCAL_1 ?
		/* LOCAL_1 -> addr 294 arity 0 */
		// match LOCAL_1 -> addr 294->addr ?
		if(0 + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = 0 + 0;
			p.rule[addr_NT] = 7;
			closure_addr(a, 0 + 0);
		}
		break;
		case 298: /* LOCAL_4 */
		//LOCAL_4 -> addr 293->LOCAL_4 ?
		/* LOCAL_4 -> addr 293 arity 0 */
		// match LOCAL_4 -> addr 293->addr ?
		if(0 + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = 0 + 0;
			p.rule[addr_NT] = 6;
			closure_addr(a, 0 + 0);
		}
		break;
		case 299: /* LOCAL_8 */
		//LOCAL_8 -> addr 292->LOCAL_8 ?
		/* LOCAL_8 -> addr 292 arity 0 */
		// match LOCAL_8 -> addr 292->addr ?
		if(0 + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = 0 + 0;
			p.rule[addr_NT] = 5;
			closure_addr(a, 0 + 0);
		}
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
		//EXTERN_0 -> inst 299->EXTERN_0 ?
		/* EXTERN_0 -> inst 299 arity 0 */
		// match EXTERN_0 -> inst 299->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 89;
		}
		break;
		case 329: /* GLOBAL_1 */
		break;
		case 330: /* GLOBAL_4 */
		break;
		case 331: /* GLOBAL_8 */
		//GLOBAL_8 -> const 230->GLOBAL_8 ?
		/* GLOBAL_8 -> const 230 arity 0 */
		// match GLOBAL_8 -> const 230->const ?
		if(0 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 0 + 0;
			p.rule[const_NT] = 3;
			closure_const(a, 0 + 0);
		}
		//GLOBAL_8 -> immed 235->GLOBAL_8 ?
		/* GLOBAL_8 -> immed 235 arity 0 */
		// match GLOBAL_8 -> immed 235->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 8;
			closure_immed(a, 0 + 0);
		}
		break;
		case 336: /* LABEL_0 */
		//LABEL_0 -> const 232->LABEL_0 ?
		/* LABEL_0 -> const 232 arity 0 */
		// match LABEL_0 -> const 232->const ?
		if(50 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 50 + 0;
			p.rule[const_NT] = 5;
			closure_const(a, 50 + 0);
		}
		//LABEL_0 -> inst 297->LABEL_0 ?
		/* LABEL_0 -> inst 297 arity 0 */
		// match LABEL_0 -> inst 297->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 87;
		}
		break;
		case 344: /* DLABEL_0 */
		//DLABEL_0 -> const 233->DLABEL_0 ?
		/* DLABEL_0 -> const 233 arity 0 */
		// match DLABEL_0 -> const 233->const ?
		if(50 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 50 + 0;
			p.rule[const_NT] = 6;
			closure_const(a, 50 + 0);
		}
		//DLABEL_0 -> inst 298->DLABEL_0 ?
		/* DLABEL_0 -> inst 298 arity 0 */
		// match DLABEL_0 -> inst 298->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 88;
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
		/* [CAST_FROM1_4 immed] -> immed 68 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM1_4 immed] -> immed 68->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 3;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM1_4 tvm] -> tv 69 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [CAST_FROM1_4 tvm] -> tv 69->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 3;
			closure_tv(a, c + 0);
		}
		break;
		case 355: /* CAST_FROM1_8 */
		label(a.getLeft());
		/* [CAST_FROM1_8 immed] -> immed 66 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM1_8 immed] -> immed 66->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 2;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM1_8 tvm] -> tv 67 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [CAST_FROM1_8 tvm] -> tv 67->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 2;
			closure_tv(a, c + 0);
		}
		break;
		case 358: /* CAST_FROM11_4 */
		break;
		case 359: /* CAST_FROM11_8 */
		break;
		case 361: /* CAST_FROM4_1 */
		label(a.getLeft());
		/* [CAST_FROM4_1 immed] -> immed 72 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM4_1 immed] -> immed 72->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 5;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM4_1 mem] -> mem 73 */		c = a.getLeft().getReWriteState().cost[mem_NT] + 
0;
		// match [CAST_FROM4_1 mem] -> mem 73->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 2;
			closure_mem(a, c + 0);
		}
		/* [CAST_FROM4_1 t] -> t 74 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [CAST_FROM4_1 t] -> t 74->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 60;
			closure_t(a, c + 0);
		}
		break;
		case 362: /* CAST_FROM4_4 */
		label(a.getLeft());
		/* [CAST_FROM4_4 immed] -> immed 63 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM4_4 immed] -> immed 63->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 1;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM4_4 tv] -> tv 64 */		c = a.getLeft().getReWriteState().cost[tv_NT] + 
0;
		// match [CAST_FROM4_4 tv] -> tv 64->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 1;
			closure_tv(a, c + 0);
		}
		/* [CAST_FROM4_4 mem] -> mem 65 */		c = a.getLeft().getReWriteState().cost[mem_NT] + 
0;
		// match [CAST_FROM4_4 mem] -> mem 65->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 1;
			closure_mem(a, c + 0);
		}
		break;
		case 363: /* CAST_FROM4_8 */
		label(a.getLeft());
		/* [CAST_FROM4_8 immed] -> immed 70 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM4_8 immed] -> immed 70->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 4;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM4_8 tvm] -> tv 71 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [CAST_FROM4_8 tvm] -> tv 71->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 4;
			closure_tv(a, c + 0);
		}
		break;
		case 365: /* CAST_FROM41_1 */
		break;
		case 366: /* CAST_FROM41_4 */
		break;
		case 367: /* CAST_FROM41_8 */
		break;
		case 369: /* CAST_FROM8_1 */
		label(a.getLeft());
		/* [CAST_FROM8_1 immed] -> immed 78 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM8_1 immed] -> immed 78->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 7;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM8_1 mem] -> mem 79 */		c = a.getLeft().getReWriteState().cost[mem_NT] + 
0;
		// match [CAST_FROM8_1 mem] -> mem 79->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 4;
			closure_mem(a, c + 0);
		}
		/* [CAST_FROM8_1 t] -> t 80 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [CAST_FROM8_1 t] -> t 80->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 62;
			closure_t(a, c + 0);
		}
		break;
		case 370: /* CAST_FROM8_4 */
		label(a.getLeft());
		/* [CAST_FROM8_4 immed] -> immed 75 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
0;
		// match [CAST_FROM8_4 immed] -> immed 75->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 6;
			closure_immed(a, c + 0);
		}
		/* [CAST_FROM8_4 mem] -> mem 76 */		c = a.getLeft().getReWriteState().cost[mem_NT] + 
0;
		// match [CAST_FROM8_4 mem] -> mem 76->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 3;
			closure_mem(a, c + 0);
		}
		/* [CAST_FROM8_4 t] -> t 77 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [CAST_FROM8_4 t] -> t 77->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 61;
			closure_t(a, c + 0);
		}
		break;
		case 373: /* CAST_FROM81_1 */
		break;
		case 374: /* CAST_FROM81_4 */
		break;
		case 377: /* TREAT_AS_1 */
		label(a.getLeft());
		/* [TREAT_AS_1 tvm] -> tvm 83 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
0;
		// match [TREAT_AS_1 tvm] -> tvm 83->tvm ?
		if(c + 0 < p.cost[tvm_NT]) {
			p.cost[tvm_NT] = c + 0;
			p.rule[tvm_NT] = 3;
			closure_tvm(a, c + 0);
		}
		break;
		case 378: /* TREAT_AS_4 */
		label(a.getLeft());
		/* [TREAT_AS_4 tvm] -> tvm 82 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
0;
		// match [TREAT_AS_4 tvm] -> tvm 82->tvm ?
		if(c + 0 < p.cost[tvm_NT]) {
			p.cost[tvm_NT] = c + 0;
			p.rule[tvm_NT] = 2;
			closure_tvm(a, c + 0);
		}
		break;
		case 379: /* TREAT_AS_8 */
		label(a.getLeft());
		/* [TREAT_AS_8 tvm] -> tvm 81 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
0;
		// match [TREAT_AS_8 tvm] -> tvm 81->tvm ?
		if(c + 0 < p.cost[tvm_NT]) {
			p.cost[tvm_NT] = c + 0;
			p.rule[tvm_NT] = 1;
			closure_tvm(a, c + 0);
		}
		break;
		case 381: /* TREAT_AS1_1 */
		break;
		case 382: /* TREAT_AS1_4 */
		break;
		case 383: /* TREAT_AS1_8 */
		break;
		case 384: /* CAST_CHECK_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [CAST_CHECK_0 tv tvi] -> tv 84 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
10;
		// match [CAST_CHECK_0 tv tvi] -> tv 84->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 5;
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
		//CONST_1 -> immed 238->CONST_1 ?
		/* CONST_1 -> immed 238 arity 0 */
		// match CONST_1 -> immed 238->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 11;
			closure_immed(a, 0 + 0);
		}
		break;
		case 410: /* CONST_4 */
		//CONST_4 -> immed 237->CONST_4 ?
		/* CONST_4 -> immed 237 arity 0 */
		// match CONST_4 -> immed 237->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 10;
			closure_immed(a, 0 + 0);
		}
		break;
		case 411: /* CONST_8 */
		//CONST_8 -> const 231->CONST_8 ?
		/* CONST_8 -> const 231 arity 0 */
		// match CONST_8 -> const 231->const ?
		if(0 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 0 + 0;
			p.rule[const_NT] = 4;
			closure_const(a, 0 + 0);
		}
		//CONST_8 -> immed 236->CONST_8 ?
		/* CONST_8 -> immed 236 arity 0 */
		// match CONST_8 -> immed 236->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 9;
			closure_immed(a, 0 + 0);
		}
		break;
		case 416: /* CONST_STR_0 */
		//CONST_STR_0 -> mem 211->CONST_STR_0 ?
		/* CONST_STR_0 -> mem 211 arity 0 */
		c = ( ITree.wantPIC(0,32768) );		// match CONST_STR_0 -> mem 211->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 5;
			closure_mem(a, c + 0);
		}
		//CONST_STR_0 -> const 212->CONST_STR_0 ?
		/* CONST_STR_0 -> const 212 arity 0 */
		c = ( ITree.wantPIC(32768,0) );		// match CONST_STR_0 -> const 212->const ?
		if(c + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = c + 0;
			p.rule[const_NT] = 1;
			closure_const(a, c + 0);
		}
		break;
		case 424: /* CONST_CSTR_0 */
		//CONST_CSTR_0 -> mem 213->CONST_CSTR_0 ?
		/* CONST_CSTR_0 -> mem 213 arity 0 */
		c = ( ITree.wantPIC(0,32768) );		// match CONST_CSTR_0 -> mem 213->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 6;
			closure_mem(a, c + 0);
		}
		//CONST_CSTR_0 -> const 214->CONST_CSTR_0 ?
		/* CONST_CSTR_0 -> const 214 arity 0 */
		c = ( ITree.wantPIC(32768,0) );		// match CONST_CSTR_0 -> const 214->const ?
		if(c + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = c + 0;
			p.rule[const_NT] = 2;
			closure_const(a, c + 0);
		}
		break;
		case 432: /* BOX_0 */
		label(a.getLeft());
		/* [BOX_0 t] -> t 210 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [BOX_0 t] -> t 210->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 64;
			closure_t(a, c + 0);
		}
		break;
		case 441: /* BOOL_OR_1 */
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
		//CALL_0 -> inst 322->CALL_0 ?
		/* CALL_0 -> inst 322 arity 0 */
		// match CALL_0 -> inst 322->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 107;
		}
		break;
		case 496: /* STATIC_CALL_0 */
		label(a.getLeft());
		/* [STATIC_CALL_0 t] -> inst 318 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [STATIC_CALL_0 t] -> inst 318->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 103;
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
		/* [DYNAMIC_CALL_0 t] -> inst 320 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [DYNAMIC_CALL_0 t] -> inst 320->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 105;
		}
		break;
		case 512: /* STATIC_DYNAMIC_CALL_0 */
		break;
		case 520: /* STATIC_CALL_DISCARD_0 */
		//STATIC_CALL_DISCARD_0 -> inst 319->STATIC_CALL_DISCARD_0 ?
		/* STATIC_CALL_DISCARD_0 -> inst 319 arity 0 */
		// match STATIC_CALL_DISCARD_0 -> inst 319->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 104;
		}
		break;
		case 528: /* DYNAMIC_CALL_DISCARD_0 */
		//DYNAMIC_CALL_DISCARD_0 -> inst 321->DYNAMIC_CALL_DISCARD_0 ?
		/* DYNAMIC_CALL_DISCARD_0 -> inst 321 arity 0 */
		// match DYNAMIC_CALL_DISCARD_0 -> inst 321->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 106;
		}
		break;
		case 536: /* STATIC_DYNAMIC_CALL_DISCARD_0 */
		break;
		case 544: /* PROC_CALL_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [PROC_CALL_0 t t] -> inst 316 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
10;
		// match [PROC_CALL_0 t t] -> inst 316->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 101;
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
		case 552: /* PROC_CALL_DISCARD_0 */
		label(a.getLeft());
		/* [PROC_CALL_DISCARD_0 t] -> inst 317 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [PROC_CALL_DISCARD_0 t] -> inst 317->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 102;
		}
		break;
		case 560: /* PROC_REF_0 */
		//PROC_REF_0 -> t 315->PROC_REF_0 ?
		/* PROC_REF_0 -> t 315 arity 0 */
		// match PROC_REF_0 -> t 315->t ?
		if(10 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 10 + 0;
			p.rule[t_NT] = 75;
			closure_t(a, 10 + 0);
		}
		break;
		case 568: /* NEW_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [NEW_0 t tvi] -> t 311 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
10;
		// match [NEW_0 t tvi] -> t 311->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 71;
			closure_t(a, c + 0);
		}
		break;
		case 576: /* NEW_FINALIZE_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [NEW_FINALIZE_0 t tvi] -> t 312 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
10;
		// match [NEW_FINALIZE_0 t tvi] -> t 312->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 72;
			closure_t(a, c + 0);
		}
		break;
		case 584: /* NEW_ARRAY_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [NEW_ARRAY_0 t tv] -> t 314 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [NEW_ARRAY_0 t tv] -> t 314->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 74;
			closure_t(a, c + 0);
		}
		break;
		case 592: /* NEW_OBJ_ARRAY_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [NEW_OBJ_ARRAY_0 t tv] -> t 313 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
10;
		// match [NEW_OBJ_ARRAY_0 t tv] -> t 313->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 73;
			closure_t(a, c + 0);
		}
		break;
	default:
		if( a.getOperator() > 592) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label12(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 600: /* NEW_GENERIC_ARRAY_0 */
		break;
		case 609: /* PAIR_1 */
		break;
		case 610: /* PAIR_4 */
		break;
		case 611: /* PAIR_8 */
		label(a.getLeft());
		label(a.getRight());
		break;
		case 617: /* PUSH_1 */
		break;
		case 618: /* PUSH_4 */
		break;
		case 619: /* PUSH_8 */
		label(a.getLeft());
		/* [PUSH_8 tvmi] -> inst 93 */		c = a.getLeft().getReWriteState().cost[tvmi_NT] + 
10;
		// match [PUSH_8 tvmi] -> inst 93->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 12;
		}
		break;
		case 625: /* POP_1 */
		break;
		case 626: /* POP_4 */
		break;
		case 627: /* POP_8 */
		label(a.getLeft());
		/* [POP_8 tvm] -> inst 94 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [POP_8 tvm] -> inst 94->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 13;
		}
		break;
		case 632: /* RET_0 */
		//RET_0 -> inst 305->RET_0 ?
		/* RET_0 -> inst 305 arity 0 */
		// match RET_0 -> inst 305->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 95;
		}
		break;
		case 641: /* STORE_1 */
		break;
		case 642: /* STORE_4 */
		break;
		case 643: /* STORE_8 */
		break;
		case 649: /* THROW_1 */
		break;
	default:
		if( a.getOperator() > 649) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label13(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 650: /* THROW_4 */
		break;
		case 651: /* THROW_8 */
		label(a.getLeft());
		/* [THROW_8 t] -> inst 323 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
10;
		// match [THROW_8 t] -> inst 323->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 108;
		}
		break;
		case 656: /* TRY_0 */
		break;
		case 664: /* START_CATCH_0 */
		break;
		case 672: /* CATCH_0 */
		break;
		case 680: /* SUSPEND_CATCH_0 */
		//SUSPEND_CATCH_0 -> inst 228->SUSPEND_CATCH_0 ?
		/* SUSPEND_CATCH_0 -> inst 228 arity 0 */
		// match SUSPEND_CATCH_0 -> inst 228->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 81;
		}
		break;
		case 688: /* END_FINALLY_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [END_FINALLY_0 t t] -> inst 227 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
0;
		// match [END_FINALLY_0 t t] -> inst 227->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 80;
		}
		break;
		case 696: /* END_CATCH_0 */
		//END_CATCH_0 -> inst 225->END_CATCH_0 ?
		/* END_CATCH_0 -> inst 225 arity 0 */
		// match END_CATCH_0 -> inst 225->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 78;
		}
		break;
	default:
		if( a.getOperator() > 696) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label14(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 704: /* END_TRY_0 */
		//END_TRY_0 -> inst 224->END_TRY_0 ?
		/* END_TRY_0 -> inst 224 arity 0 */
		// match END_TRY_0 -> inst 224->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 77;
		}
		break;
		case 712: /* COND_RETHROW_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [COND_RETHROW_0 t t] -> inst 226 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[t_NT] + 
0;
		// match [COND_RETHROW_0 t t] -> inst 226->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 79;
		}
		break;
		case 720: /* COND_RETURN_0 */
		break;
		case 729: /* THROW_RETURN_1 */
		break;
		case 730: /* THROW_RETURN_4 */
		break;
		case 731: /* THROW_RETURN_8 */
		label(a.getLeft());
		/* [THROW_RETURN_8 tv] -> inst 304 */		c = a.getLeft().getReWriteState().cost[tv_NT] + 
10;
		// match [THROW_RETURN_8 tv] -> inst 304->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 94;
		}
		break;
		case 736: /* RETURN_RETHROW_0 */
		break;
		case 744: /* ADJUST_0 */
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
		case 752: /* PUSH_EBP_0 */
		//PUSH_EBP_0 -> inst 217->PUSH_EBP_0 ?
		/* PUSH_EBP_0 -> inst 217 arity 0 */
		// match PUSH_EBP_0 -> inst 217->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 70;
		}
		break;
		case 760: /* SAVE_ALL_0 */
		//SAVE_ALL_0 -> inst 300->SAVE_ALL_0 ?
		/* SAVE_ALL_0 -> inst 300 arity 0 */
		// match SAVE_ALL_0 -> inst 300->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 90;
		}
		break;
		case 768: /* RESTORE_ALL_0 */
		//RESTORE_ALL_0 -> inst 301->RESTORE_ALL_0 ?
		/* RESTORE_ALL_0 -> inst 301 arity 0 */
		// match RESTORE_ALL_0 -> inst 301->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 91;
		}
		break;
		case 776: /* JUMP_0 */
		//JUMP_0 -> inst 209->JUMP_0 ?
		/* JUMP_0 -> inst 209 arity 0 */
		// match JUMP_0 -> inst 209->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 67;
		}
		break;
		case 784: /* DUMMY_JUMP_0 */
		//DUMMY_JUMP_0 -> inst 324->DUMMY_JUMP_0 ?
		/* DUMMY_JUMP_0 -> inst 324 arity 0 */
		// match DUMMY_JUMP_0 -> inst 324->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 109;
		}
		break;
		case 793: /* CMP_1 */
		break;
		case 794: /* CMP_4 */
		break;
		case 795: /* CMP_8 */
		break;
		case 797: /* CMP2_1 */
		break;
		case 798: /* CMP2_4 */
		break;
		case 799: /* CMP2_8 */
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
		case 801: /* DECBNN_1 */
		break;
		case 802: /* DECBNN_4 */
		break;
		case 803: /* DECBNN_8 */
		label(a.getLeft());
		/* [DECBNN_8 tvm] -> inst 186 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
20;
		// match [DECBNN_8 tvm] -> inst 186->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 44;
		}
		break;
		case 805: /* DECBNN1_1 */
		break;
		case 806: /* DECBNN1_4 */
		break;
		case 807: /* DECBNN1_8 */
		break;
		case 808: /* BRANCH_0 */
		label(a.getLeft());
		/* [BRANCH_0 compare] -> inst 187 */		c = a.getLeft().getReWriteState().cost[compare_NT] + 
10;
		// match [BRANCH_0 compare] -> inst 187->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 45;
		}
		/* [BRANCH_0 immed] -> inst 188 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCH_0 immed] -> inst 188->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 46;
		}
		/* [BRANCH_0 immed] -> inst 189 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCH_0 immed] -> inst 189->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 47;
		}
		break;
		case 812: /* BRANCH1_0 */
		break;
		case 817: /* BRANCHZ_1 */
		label(a.getLeft());
		/* [BRANCHZ_1 immed] -> inst 198 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHZ_1 immed] -> inst 198->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 56;
		}
		/* [BRANCHZ_1 immed] -> inst 199 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHZ_1 immed] -> inst 199->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 57;
		}
		/* [BRANCHZ_1 tvm] -> inst 207 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHZ_1 tvm] -> inst 207->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 65;
		}
		break;
		case 818: /* BRANCHZ_4 */
		label(a.getLeft());
		/* [BRANCHZ_4 immed] -> inst 194 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHZ_4 immed] -> inst 194->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 52;
		}
		/* [BRANCHZ_4 immed] -> inst 195 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHZ_4 immed] -> inst 195->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 53;
		}
		/* [BRANCHZ_4 tvm] -> inst 205 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHZ_4 tvm] -> inst 205->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 63;
		}
		break;
		case 819: /* BRANCHZ_8 */
		label(a.getLeft());
		/* [BRANCHZ_8 immed] -> inst 190 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHZ_8 immed] -> inst 190->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 48;
		}
		/* [BRANCHZ_8 immed] -> inst 191 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHZ_8 immed] -> inst 191->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 49;
		}
		/* [BRANCHZ_8 tvm] -> inst 203 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHZ_8 tvm] -> inst 203->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 61;
		}
		break;
		case 821: /* BRANCHZ1_1 */
		break;
		case 822: /* BRANCHZ1_4 */
		break;
		case 823: /* BRANCHZ1_8 */
		break;
		case 825: /* BRANCHNZ_1 */
		label(a.getLeft());
		/* [BRANCHNZ_1 immed] -> inst 200 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHNZ_1 immed] -> inst 200->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 58;
		}
		/* [BRANCHNZ_1 immed] -> inst 201 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHNZ_1 immed] -> inst 201->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 59;
		}
		/* [BRANCHNZ_1 tvm] -> inst 208 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHNZ_1 tvm] -> inst 208->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 66;
		}
		break;
		case 826: /* BRANCHNZ_4 */
		label(a.getLeft());
		/* [BRANCHNZ_4 immed] -> inst 196 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHNZ_4 immed] -> inst 196->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 54;
		}
		/* [BRANCHNZ_4 immed] -> inst 197 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHNZ_4 immed] -> inst 197->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 55;
		}
		/* [BRANCHNZ_4 tvm] -> inst 206 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHNZ_4 tvm] -> inst 206->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 64;
		}
		break;
		case 827: /* BRANCHNZ_8 */
		label(a.getLeft());
		/* [BRANCHNZ_8 immed] -> inst 192 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",32768,0) );
		// match [BRANCHNZ_8 immed] -> inst 192->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 50;
		}
		/* [BRANCHNZ_8 immed] -> inst 193 */		c = a.getLeft().getReWriteState().cost[immed_NT] + 
( a.getLeft().valueIs("0",0,32768) );
		// match [BRANCHNZ_8 immed] -> inst 193->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 51;
		}
		/* [BRANCHNZ_8 tvm] -> inst 204 */		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
10;
		// match [BRANCHNZ_8 tvm] -> inst 204->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 62;
		}
		break;
		case 829: /* BRANCHNZ1_1 */
		break;
		case 830: /* BRANCHNZ1_4 */
		break;
		case 831: /* BRANCHNZ1_8 */
		break;
		case 832: /* JE_0 */
		break;
		case 840: /* JNE_0 */
		break;
		case 848: /* JG_0 */
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
		case 856: /* JL_0 */
		break;
		case 864: /* JGE_0 */
		break;
		case 872: /* JLE_0 */
		break;
		case 880: /* JGU_0 */
		break;
		case 888: /* JLU_0 */
		break;
		case 896: /* JGEU_0 */
		break;
	default:
		if( a.getOperator() > 896) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label18(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 904: /* JLEU_0 */
		break;
		case 913: /* SETE_1 */
		break;
		case 921: /* SETNE_1 */
		break;
		case 929: /* SETG_1 */
		break;
		case 937: /* SETL_1 */
		break;
		case 945: /* SETGE_1 */
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
		case 953: /* SETLE_1 */
		break;
		case 961: /* SETGU_1 */
		break;
		case 969: /* SETLU_1 */
		break;
		case 977: /* SETGEU_1 */
		break;
		case 985: /* SETLEU_1 */
		break;
		case 992: /* RESERVE_0 */
		//RESERVE_0 -> inst 302->RESERVE_0 ?
		/* RESERVE_0 -> inst 302 arity 0 */
		// match RESERVE_0 -> inst 302->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 92;
		}
		break;
	default:
		if( a.getOperator() > 992) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label20(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1000: /* RELEASE_0 */
		//RELEASE_0 -> inst 303->RELEASE_0 ?
		/* RELEASE_0 -> inst 303 arity 0 */
		// match RELEASE_0 -> inst 303->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 93;
		}
		break;
		case 1008: /* ENTER_0 */
		//ENTER_0 -> inst 295->ENTER_0 ?
		/* ENTER_0 -> inst 295 arity 0 */
		// match ENTER_0 -> inst 295->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 85;
		}
		break;
		case 1016: /* LEAVE_0 */
		//LEAVE_0 -> inst 296->LEAVE_0 ?
		/* LEAVE_0 -> inst 296 arity 0 */
		// match LEAVE_0 -> inst 296->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 86;
		}
		break;
		case 1025: /* RESULT_1 */
		break;
		case 1026: /* RESULT_4 */
		break;
		case 1027: /* RESULT_8 */
		label(a.getLeft());
		/* [RESULT_8 t] -> inst 215 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [RESULT_8 t] -> inst 215->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 68;
		}
		/* [RESULT_8 t] -> param 258 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
40;
		// match [RESULT_8 t] -> param 258->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 2;
			closure_param(a, c + 0);
		}
		break;
		case 1032: /* RESULT_F_0 */
		label(a.getLeft());
		/* [RESULT_F_0 t] -> inst 216 */		c = a.getLeft().getReWriteState().cost[t_NT] + 
0;
		// match [RESULT_F_0 t] -> inst 216->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 69;
		}
		break;
		case 1040: /* ENTER_LOOP_0 */
		//ENTER_LOOP_0 -> inst 306->ENTER_LOOP_0 ?
		/* ENTER_LOOP_0 -> inst 306 arity 0 */
		// match ENTER_LOOP_0 -> inst 306->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 96;
		}
		break;
		case 1048: /* LEAVE_LOOP_0 */
		//LEAVE_LOOP_0 -> inst 307->LEAVE_LOOP_0 ?
		/* LEAVE_LOOP_0 -> inst 307 arity 0 */
		// match LEAVE_LOOP_0 -> inst 307->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 97;
		}
		break;
	default:
		if( a.getOperator() > 1048) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label21(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1056: /* LINE_0 */
		//LINE_0 -> inst 202->LINE_0 ?
		/* LINE_0 -> inst 202 arity 0 */
		// match LINE_0 -> inst 202->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 60;
		}
		break;
		case 1065: /* REG_VAR_1 */
		//REG_VAR_1 -> v 271->REG_VAR_1 ?
		/* REG_VAR_1 -> v 271 arity 0 */
		// match REG_VAR_1 -> v 271->v ?
		if(0 + 0 < p.cost[v_NT]) {
			p.cost[v_NT] = 0 + 0;
			p.rule[v_NT] = 3;
			closure_v(a, 0 + 0);
		}
		break;
		case 1066: /* REG_VAR_4 */
		//REG_VAR_4 -> v 270->REG_VAR_4 ?
		/* REG_VAR_4 -> v 270 arity 0 */
		// match REG_VAR_4 -> v 270->v ?
		if(0 + 0 < p.cost[v_NT]) {
			p.cost[v_NT] = 0 + 0;
			p.rule[v_NT] = 2;
			closure_v(a, 0 + 0);
		}
		break;
		case 1067: /* REG_VAR_8 */
		//REG_VAR_8 -> v 269->REG_VAR_8 ?
		/* REG_VAR_8 -> v 269 arity 0 */
		// match REG_VAR_8 -> v 269->v ?
		if(0 + 0 < p.cost[v_NT]) {
			p.cost[v_NT] = 0 + 0;
			p.rule[v_NT] = 1;
			closure_v(a, 0 + 0);
		}
		break;
		case 1073: /* REGISTER_1 */
		//REGISTER_1 -> t 248->REGISTER_1 ?
		/* REGISTER_1 -> t 248 arity 0 */
		// match REGISTER_1 -> t 248->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 70;
			closure_t(a, 0 + 0);
		}
		break;
		case 1074: /* REGISTER_4 */
		//REGISTER_4 -> t 247->REGISTER_4 ?
		/* REGISTER_4 -> t 247 arity 0 */
		// match REGISTER_4 -> t 247->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 69;
			closure_t(a, 0 + 0);
		}
		break;
		case 1075: /* REGISTER_8 */
		//REGISTER_8 -> t 246->REGISTER_8 ?
		/* REGISTER_8 -> t 246 arity 0 */
		// match REGISTER_8 -> t 246->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 68;
			closure_t(a, 0 + 0);
		}
		break;
		case 1081: /* TEMP_1 */
		//TEMP_1 -> t 245->TEMP_1 ?
		/* TEMP_1 -> t 245 arity 0 */
		// match TEMP_1 -> t 245->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 67;
			closure_t(a, 0 + 0);
		}
		break;
		case 1082: /* TEMP_4 */
		//TEMP_4 -> t 244->TEMP_4 ?
		/* TEMP_4 -> t 244 arity 0 */
		// match TEMP_4 -> t 244->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 66;
			closure_t(a, 0 + 0);
		}
		break;
		case 1083: /* TEMP_8 */
		//TEMP_8 -> t 243->TEMP_8 ?
		/* TEMP_8 -> t 243 arity 0 */
		// match TEMP_8 -> t 243->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 65;
			closure_t(a, 0 + 0);
		}
		break;
		case 1089: /* MEMORY_1 */
		break;
		case 1090: /* MEMORY_4 */
		break;
		case 1091: /* MEMORY_8 */
		break;
		case 1097: /* PARAM0_1 */
		break;
		case 1098: /* PARAM0_4 */
		break;
		case 1099: /* PARAM0_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM0_8 t param] -> param 260 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM0_8 t param] -> param 260->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 3;
			closure_param(a, c + 0);
		}
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
		case 1105: /* PARAM1_1 */
		break;
		case 1106: /* PARAM1_4 */
		break;
		case 1107: /* PARAM1_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM1_8 t param] -> param 261 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM1_8 t param] -> param 261->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 4;
			closure_param(a, c + 0);
		}
		break;
		case 1113: /* PARAM2_1 */
		break;
		case 1114: /* PARAM2_4 */
		break;
		case 1115: /* PARAM2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM2_8 t param] -> param 262 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM2_8 t param] -> param 262->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 5;
			closure_param(a, c + 0);
		}
		break;
		case 1121: /* PARAM3_1 */
		break;
		case 1122: /* PARAM3_4 */
		break;
		case 1123: /* PARAM3_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM3_8 t param] -> param 263 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM3_8 t param] -> param 263->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 6;
			closure_param(a, c + 0);
		}
		break;
		case 1129: /* PARAM4_1 */
		break;
		case 1130: /* PARAM4_4 */
		break;
		case 1131: /* PARAM4_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM4_8 t param] -> param 264 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM4_8 t param] -> param 264->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 7;
			closure_param(a, c + 0);
		}
		break;
		case 1137: /* PARAM5_1 */
		break;
		case 1138: /* PARAM5_4 */
		break;
		case 1139: /* PARAM5_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [PARAM5_8 t param] -> param 265 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[param_NT] + 
0;
		// match [PARAM5_8 t param] -> param 265->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 8;
			closure_param(a, c + 0);
		}
		break;
		case 1145: /* ARG0_1 */
		break;
		case 1146: /* ARG0_4 */
		break;
		case 1147: /* ARG0_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG0_8 t arg] -> arg 251 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG0_8 t arg] -> arg 251->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 2;
			closure_arg(a, c + 0);
		}
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
		case 1153: /* ARG1_1 */
		break;
		case 1154: /* ARG1_4 */
		break;
		case 1155: /* ARG1_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG1_8 t arg] -> arg 252 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG1_8 t arg] -> arg 252->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 3;
			closure_arg(a, c + 0);
		}
		break;
		case 1161: /* ARG2_1 */
		break;
		case 1162: /* ARG2_4 */
		break;
		case 1163: /* ARG2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG2_8 t arg] -> arg 253 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG2_8 t arg] -> arg 253->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 4;
			closure_arg(a, c + 0);
		}
		break;
		case 1169: /* ARG3_1 */
		break;
		case 1170: /* ARG3_4 */
		break;
		case 1171: /* ARG3_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG3_8 t arg] -> arg 254 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG3_8 t arg] -> arg 254->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 5;
			closure_arg(a, c + 0);
		}
		break;
		case 1177: /* ARG4_1 */
		break;
		case 1178: /* ARG4_4 */
		break;
		case 1179: /* ARG4_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG4_8 t arg] -> arg 255 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG4_8 t arg] -> arg 255->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 6;
			closure_arg(a, c + 0);
		}
		break;
		case 1185: /* ARG5_1 */
		break;
		case 1186: /* ARG5_4 */
		break;
		case 1187: /* ARG5_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ARG5_8 t arg] -> arg 256 */
		c = a.getLeft().getReWriteState().cost[t_NT] + 
a.getRight().getReWriteState().cost[arg_NT] + 
0;
		// match [ARG5_8 t arg] -> arg 256->arg ?
		if(c + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = c + 0;
			p.rule[arg_NT] = 7;
			closure_arg(a, c + 0);
		}
		break;
		case 1192: /* INIT_REG_VAR_0 */
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
		case 1200: /* SAVE_REG_VAR_0 */
		break;
		case 1208: /* RESTORE_REG_VAR_0 */
		break;
		case 1217: /* SEQ_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SEQ_1 inst tv] -> tv 268 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
0;
		// match [SEQ_1 inst tv] -> tv 268->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 8;
			closure_tv(a, c + 0);
		}
		break;
		case 1218: /* SEQ_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SEQ_4 inst tv] -> tv 267 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
0;
		// match [SEQ_4 inst tv] -> tv 267->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 7;
			closure_tv(a, c + 0);
		}
		break;
		case 1219: /* SEQ_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SEQ_8 inst const] -> const 234 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[const_NT] + 
0;
		// match [SEQ_8 inst const] -> const 234->const ?
		if(c + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = c + 0;
			p.rule[const_NT] = 7;
			closure_const(a, c + 0);
		}
		/* [SEQ_8 inst immed] -> immed 239 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[immed_NT] + 
0;
		// match [SEQ_8 inst immed] -> immed 239->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 12;
			closure_immed(a, c + 0);
		}
		/* [SEQ_8 inst tv] -> tv 266 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[tv_NT] + 
0;
		// match [SEQ_8 inst tv] -> tv 266->tv ?
		if(c + 0 < p.cost[tv_NT]) {
			p.cost[tv_NT] = c + 0;
			p.rule[tv_NT] = 6;
			closure_tv(a, c + 0);
		}
		break;
		case 1224: /* LIST_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [LIST_0 inst inst] -> inst 2 */
		c = a.getLeft().getReWriteState().cost[inst_NT] + 
a.getRight().getReWriteState().cost[inst_NT] + 
0;
		// match [LIST_0 inst inst] -> inst 2->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 2;
		}
		break;
		case 1233: /* COPY_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [COPY_1 tvm tvi] -> inst 89 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
5;
		// match [COPY_1 tvm tvi] -> inst 89->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 8;
		}
		/* [COPY_1 tv mem] -> inst 92 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[mem_NT] + 
10;
		// match [COPY_1 tv mem] -> inst 92->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 11;
		}
		if(/* [COPY_1 tvm [ADD_1 tvm tvi]] -> inst 115 arity 2 */
			a.getRight().getOperator() == 25 /* BB ADD_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_1 tvm [ADD_1 tvm tvi]] -> inst 115->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 34;
			}
}
		if(/* [COPY_1 tvm [ADD_1 tvi tvm]] -> inst 116 arity 2 */
			a.getRight().getOperator() == 25 /* BB ADD_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_1 tvm [ADD_1 tvi tvm]] -> inst 116->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 35;
			}
}
		if(/* [COPY_1 tvm [AND_1 tvm tvi]] -> inst 117 arity 2 */
			a.getRight().getOperator() == 177 /* BB AND_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_1 tvm [AND_1 tvm tvi]] -> inst 117->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 36;
			}
}
		if(/* [COPY_1 tvm [AND_1 tvi tvm]] -> inst 118 arity 2 */
			a.getRight().getOperator() == 177 /* BB AND_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_1 tvm [AND_1 tvi tvm]] -> inst 118->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 37;
			}
}
		if(/* [COPY_1 tvm [OR_1 tvm tvi]] -> inst 119 arity 2 */
			a.getRight().getOperator() == 185 /* BB OR_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_1 tvm [OR_1 tvm tvi]] -> inst 119->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 38;
			}
}
		if(/* [COPY_1 tvm [OR_1 tvi tvm]] -> inst 120 arity 2 */
			a.getRight().getOperator() == 185 /* BB OR_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_1 tvm [OR_1 tvi tvm]] -> inst 120->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 39;
			}
}
		if(/* [COPY_1 tvm [SUB_1 tvm tvi]] -> inst 121 arity 2 */
			a.getRight().getOperator() == 33 /* BB SUB_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_1 tvm [SUB_1 tvm tvi]] -> inst 121->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 40;
			}
}
		if(/* [COPY_1 tvm [SUB_1 tvi tvm]] -> inst 122 arity 2 */
			a.getRight().getOperator() == 33 /* BB SUB_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_1 tvm [SUB_1 tvi tvm]] -> inst 122->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 41;
			}
}
		if(/* [COPY_1 tv [MUL_1 tv tvmi]] -> inst 123 arity 2 */
			a.getRight().getOperator() == 49 /* BB MUL_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getRight().getReWriteState().cost[tvmi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_1 tv [MUL_1 tv tvmi]] -> inst 123->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 42;
			}
}
		if(/* [COPY_1 tv [MUL_1 tvmi tv]] -> inst 124 arity 2 */
			a.getRight().getOperator() == 49 /* BB MUL_1*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getRight().getReWriteState().cost[tv_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_1 tv [MUL_1 tvmi tv]] -> inst 124->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 43;
			}
}
		break;
		case 1234: /* COPY_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [COPY_4 tvm tvi] -> inst 88 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
5;
		// match [COPY_4 tvm tvi] -> inst 88->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 7;
		}
		/* [COPY_4 tv mem] -> inst 91 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[mem_NT] + 
10;
		// match [COPY_4 tv mem] -> inst 91->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 10;
		}
		if(/* [COPY_4 tvm [ADD_4 tvm tvi]] -> inst 105 arity 2 */
			a.getRight().getOperator() == 26 /* BB ADD_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_4 tvm [ADD_4 tvm tvi]] -> inst 105->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 24;
			}
}
		if(/* [COPY_4 tvm [ADD_4 tvi tvm]] -> inst 106 arity 2 */
			a.getRight().getOperator() == 26 /* BB ADD_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_4 tvm [ADD_4 tvi tvm]] -> inst 106->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 25;
			}
}
		if(/* [COPY_4 tvm [AND_4 tvm tvi]] -> inst 107 arity 2 */
			a.getRight().getOperator() == 178 /* BB AND_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_4 tvm [AND_4 tvm tvi]] -> inst 107->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 26;
			}
}
		if(/* [COPY_4 tvm [AND_4 tvi tvm]] -> inst 108 arity 2 */
			a.getRight().getOperator() == 178 /* BB AND_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_4 tvm [AND_4 tvi tvm]] -> inst 108->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 27;
			}
}
		if(/* [COPY_4 tvm [OR_4 tvm tvi]] -> inst 109 arity 2 */
			a.getRight().getOperator() == 186 /* BB OR_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_4 tvm [OR_4 tvm tvi]] -> inst 109->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 28;
			}
}
		if(/* [COPY_4 tvm [OR_4 tvi tvm]] -> inst 110 arity 2 */
			a.getRight().getOperator() == 186 /* BB OR_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_4 tvm [OR_4 tvi tvm]] -> inst 110->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 29;
			}
}
		if(/* [COPY_4 tvm [SUB_4 tvm tvi]] -> inst 111 arity 2 */
			a.getRight().getOperator() == 34 /* BB SUB_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_4 tvm [SUB_4 tvm tvi]] -> inst 111->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 30;
			}
}
		if(/* [COPY_4 tvm [SUB_4 tvi tvm]] -> inst 112 arity 2 */
			a.getRight().getOperator() == 34 /* BB SUB_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_4 tvm [SUB_4 tvi tvm]] -> inst 112->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 31;
			}
}
		if(/* [COPY_4 tv [MUL_4 tv tvmi]] -> inst 113 arity 2 */
			a.getRight().getOperator() == 50 /* BB MUL_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getRight().getReWriteState().cost[tvmi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_4 tv [MUL_4 tv tvmi]] -> inst 113->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 32;
			}
}
		if(/* [COPY_4 tv [MUL_4 tvmi tv]] -> inst 114 arity 2 */
			a.getRight().getOperator() == 50 /* BB MUL_4*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getRight().getReWriteState().cost[tv_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_4 tv [MUL_4 tvmi tv]] -> inst 114->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 33;
			}
}
		break;
		case 1235: /* COPY_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [COPY_8 tvm tvi] -> inst 87 */
		c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getReWriteState().cost[tvi_NT] + 
5;
		// match [COPY_8 tvm tvi] -> inst 87->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 6;
		}
		/* [COPY_8 tv mem] -> inst 90 */
		c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getReWriteState().cost[mem_NT] + 
10;
		// match [COPY_8 tv mem] -> inst 90->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 9;
		}
		if(/* [COPY_8 tvm [ADD_8 tvm tvi]] -> inst 95 arity 2 */
			a.getRight().getOperator() == 27 /* BB ADD_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_8 tvm [ADD_8 tvm tvi]] -> inst 95->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 14;
			}
}
		if(/* [COPY_8 tvm [ADD_8 tvi tvm]] -> inst 96 arity 2 */
			a.getRight().getOperator() == 27 /* BB ADD_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_8 tvm [ADD_8 tvi tvm]] -> inst 96->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 15;
			}
}
		if(/* [COPY_8 tvm [AND_8 tvm tvi]] -> inst 97 arity 2 */
			a.getRight().getOperator() == 179 /* BB AND_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_8 tvm [AND_8 tvm tvi]] -> inst 97->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 16;
			}
}
		if(/* [COPY_8 tvm [AND_8 tvi tvm]] -> inst 98 arity 2 */
			a.getRight().getOperator() == 179 /* BB AND_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_8 tvm [AND_8 tvi tvm]] -> inst 98->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 17;
			}
}
		if(/* [COPY_8 tvm [OR_8 tvm tvi]] -> inst 99 arity 2 */
			a.getRight().getOperator() == 187 /* BB OR_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_8 tvm [OR_8 tvm tvi]] -> inst 99->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 18;
			}
}
		if(/* [COPY_8 tvm [OR_8 tvi tvm]] -> inst 100 arity 2 */
			a.getRight().getOperator() == 187 /* BB OR_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_8 tvm [OR_8 tvi tvm]] -> inst 100->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 19;
			}
}
		if(/* [COPY_8 tvm [SUB_8 tvm tvi]] -> inst 101 arity 2 */
			a.getRight().getOperator() == 35 /* BB SUB_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getRight().getReWriteState().cost[tvi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_8 tvm [SUB_8 tvm tvi]] -> inst 101->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 20;
			}
}
		if(/* [COPY_8 tvm [SUB_8 tvi tvm]] -> inst 102 arity 2 */
			a.getRight().getOperator() == 35 /* BB SUB_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tvm_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvi_NT] + 
a.getRight().getRight().getReWriteState().cost[tvm_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_8 tvm [SUB_8 tvi tvm]] -> inst 102->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 21;
			}
}
		if(/* [COPY_8 tv [MUL_8 tv tvmi]] -> inst 103 arity 2 */
			a.getRight().getOperator() == 51 /* BB MUL_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getRight().getReWriteState().cost[tvmi_NT] + 
( a.mem2mem(10,32768) );
			// match [COPY_8 tv [MUL_8 tv tvmi]] -> inst 103->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 22;
			}
}
		if(/* [COPY_8 tv [MUL_8 tvmi tv]] -> inst 104 arity 2 */
			a.getRight().getOperator() == 51 /* BB MUL_8*/
		) {
			c = a.getLeft().getReWriteState().cost[tv_NT] + 
a.getRight().getLeft().getReWriteState().cost[tvmi_NT] + 
a.getRight().getRight().getReWriteState().cost[tv_NT] + 
( a.mem2memR(10,32768) );
			// match [COPY_8 tv [MUL_8 tvmi tv]] -> inst 104->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 23;
			}
}
		break;
		case 1240: /* STATIC_0 */
		//STATIC_0 -> inst 220->STATIC_0 ?
		/* STATIC_0 -> inst 220 arity 0 */
		// match STATIC_0 -> inst 220->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 73;
		}
		break;
		case 1248: /* TEXT_0 */
		//TEXT_0 -> inst 221->TEXT_0 ?
		/* TEXT_0 -> inst 221 arity 0 */
		// match TEXT_0 -> inst 221->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 74;
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
		case 1256: /* DATA_0 */
		//DATA_0 -> inst 222->DATA_0 ?
		/* DATA_0 -> inst 222 arity 0 */
		// match DATA_0 -> inst 222->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 75;
		}
		break;
		case 1264: /* RODATA_0 */
		//RODATA_0 -> inst 223->RODATA_0 ?
		/* RODATA_0 -> inst 223 arity 0 */
		// match RODATA_0 -> inst 223->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 76;
		}
		break;
		case 1272: /* UNWIND_0 */
		break;
		case 1280: /* PUSHSEG_0 */
		//PUSHSEG_0 -> inst 218->PUSHSEG_0 ?
		/* PUSHSEG_0 -> inst 218 arity 0 */
		// match PUSHSEG_0 -> inst 218->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 71;
		}
		break;
		case 1288: /* POPSEG_0 */
		//POPSEG_0 -> inst 219->POPSEG_0 ?
		/* POPSEG_0 -> inst 219 arity 0 */
		// match POPSEG_0 -> inst 219->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 72;
		}
		break;
		case 1296: /* RELOC_0 */
		break;
	default:
		if( a.getOperator() > 1296) {
			throw new System.Exception( "label: bad terminal " + a.getOperator() );
		}	}
}
void label26(ITree a, State p) {
	int c;
	if( a == null ) throw new System.Exception("label: null tree");
	switch( a.getOperator() ) {
		case 1305: /* DEFINT_1 */
		//DEFINT_1 -> inst 327->DEFINT_1 ?
		/* DEFINT_1 -> inst 327 arity 0 */
		// match DEFINT_1 -> inst 327->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 112;
		}
		break;
		case 1306: /* DEFINT_4 */
		//DEFINT_4 -> inst 326->DEFINT_4 ?
		/* DEFINT_4 -> inst 326 arity 0 */
		// match DEFINT_4 -> inst 326->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 111;
		}
		break;
		case 1307: /* DEFINT_8 */
		//DEFINT_8 -> inst 325->DEFINT_8 ?
		/* DEFINT_8 -> inst 325 arity 0 */
		// match DEFINT_8 -> inst 325->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 110;
		}
		break;
	default:
		if( a.getOperator() > 1307) {
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
	else if( o < 1300) { label25(a,p); }
	else label26(a,p); }
ITree[] kids( ITree p, int eruleno ) {
	ITree[] result;
	if( p == null ) throw new System.Exception("kids: null tree");
	switch( eruleno ) {
	case
	327/* DEFINT_1 -> inst 327 */,
	326/* DEFINT_4 -> inst 326 */,
	325/* DEFINT_8 -> inst 325 */,
	324/* DUMMY_JUMP_0 -> inst 324 */,
	322/* CALL_0 -> inst 322 */,
	321/* DYNAMIC_CALL_DISCARD_0 -> inst 321 */,
	319/* STATIC_CALL_DISCARD_0 -> inst 319 */,
	315/* PROC_REF_0 -> t 315 */,
	310/* BOUNDS_L_0 -> inst 310 */,
	307/* LEAVE_LOOP_0 -> inst 307 */,
	306/* ENTER_LOOP_0 -> inst 306 */,
	305/* RET_0 -> inst 305 */,
	303/* RELEASE_0 -> inst 303 */,
	302/* RESERVE_0 -> inst 302 */,
	301/* RESTORE_ALL_0 -> inst 301 */,
	300/* SAVE_ALL_0 -> inst 300 */,
	299/* EXTERN_0 -> inst 299 */,
	298/* DLABEL_0 -> inst 298 */,
	297/* LABEL_0 -> inst 297 */,
	296/* LEAVE_0 -> inst 296 */,
	295/* ENTER_0 -> inst 295 */,
	294/* LOCAL_1 -> addr 294 */,
	293/* LOCAL_4 -> addr 293 */,
	292/* LOCAL_8 -> addr 292 */,
	271/* REG_VAR_1 -> v 271 */,
	270/* REG_VAR_4 -> v 270 */,
	269/* REG_VAR_8 -> v 269 */,
	257/* COMMENT_0 -> param 257 */,
	249/* COMMENT_0 -> arg 249 */,
	248/* REGISTER_1 -> t 248 */,
	247/* REGISTER_4 -> t 247 */,
	246/* REGISTER_8 -> t 246 */,
	245/* TEMP_1 -> t 245 */,
	244/* TEMP_4 -> t 244 */,
	243/* TEMP_8 -> t 243 */,
	238/* CONST_1 -> immed 238 */,
	237/* CONST_4 -> immed 237 */,
	236/* CONST_8 -> immed 236 */,
	235/* GLOBAL_8 -> immed 235 */,
	233/* DLABEL_0 -> const 233 */,
	232/* LABEL_0 -> const 232 */,
	231/* CONST_8 -> const 231 */,
	230/* GLOBAL_8 -> const 230 */,
	229/* [INDIRECT_8 GLOBAL_8] -> mem 229 */,
	228/* SUSPEND_CATCH_0 -> inst 228 */,
	225/* END_CATCH_0 -> inst 225 */,
	224/* END_TRY_0 -> inst 224 */,
	223/* RODATA_0 -> inst 223 */,
	222/* DATA_0 -> inst 222 */,
	221/* TEXT_0 -> inst 221 */,
	220/* STATIC_0 -> inst 220 */,
	219/* POPSEG_0 -> inst 219 */,
	218/* PUSHSEG_0 -> inst 218 */,
	217/* PUSH_EBP_0 -> inst 217 */,
	214/* CONST_CSTR_0 -> const 214 */,
	213/* CONST_CSTR_0 -> mem 213 */,
	212/* CONST_STR_0 -> const 212 */,
	211/* CONST_STR_0 -> mem 211 */,
	209/* JUMP_0 -> inst 209 */,
	202/* LINE_0 -> inst 202 */,
	1/* COMMENT_0 -> inst 1 */:
		result = new ITree[0];

	case
	316/* [PROC_CALL_0 t t] -> inst 316 */,
	314/* [NEW_ARRAY_0 t tv] -> t 314 */,
	313/* [NEW_OBJ_ARRAY_0 t tv] -> t 313 */,
	312/* [NEW_FINALIZE_0 t tvi] -> t 312 */,
	311/* [NEW_0 t tvi] -> t 311 */,
	309/* [BOUNDS_R_0 tv tv] -> inst 309 */,
	308/* [BOUNDS_0 tv tv] -> inst 308 */,
	289/* [ADD_8 index base] -> addr 289 */,
	288/* [ADD_8 base index] -> addr 288 */,
	286/* [MUL_8 const tv] -> index 286 */,
	285/* [MUL_8 tv const] -> index 285 */,
	282/* [ADD_8 tv const] -> base 282 */,
	281/* [ADD_8 const tv] -> base 281 */,
	268/* [SEQ_1 inst tv] -> tv 268 */,
	267/* [SEQ_4 inst tv] -> tv 267 */,
	266/* [SEQ_8 inst tv] -> tv 266 */,
	265/* [PARAM5_8 t param] -> param 265 */,
	264/* [PARAM4_8 t param] -> param 264 */,
	263/* [PARAM3_8 t param] -> param 263 */,
	262/* [PARAM2_8 t param] -> param 262 */,
	261/* [PARAM1_8 t param] -> param 261 */,
	260/* [PARAM0_8 t param] -> param 260 */,
	256/* [ARG5_8 t arg] -> arg 256 */,
	255/* [ARG4_8 t arg] -> arg 255 */,
	254/* [ARG3_8 t arg] -> arg 254 */,
	253/* [ARG2_8 t arg] -> arg 253 */,
	252/* [ARG1_8 t arg] -> arg 252 */,
	251/* [ARG0_8 t arg] -> arg 251 */,
	239/* [SEQ_8 inst immed] -> immed 239 */,
	234/* [SEQ_8 inst const] -> const 234 */,
	227/* [END_FINALLY_0 t t] -> inst 227 */,
	226/* [COND_RETHROW_0 t t] -> inst 226 */,
	184/* [LEU_1 tvi tvm] -> compare 184 */,
	183/* [LEU_1 tvm tvi] -> compare 183 */,
	182/* [GEU_1 tvi tvm] -> compare 182 */,
	181/* [GEU_1 tvm tvi] -> compare 181 */,
	180/* [LTU_1 tvi tvm] -> compare 180 */,
	179/* [LTU_1 tvm tvi] -> compare 179 */,
	178/* [GTU_1 tvi tvm] -> compare 178 */,
	177/* [GTU_1 tvm tvi] -> compare 177 */,
	176/* [LE_1 tvi tvm] -> compare 176 */,
	175/* [LE_1 tvm tvi] -> compare 175 */,
	174/* [GE_1 tvi tvm] -> compare 174 */,
	173/* [GE_1 tvm tvi] -> compare 173 */,
	172/* [LT_1 tvi tvm] -> compare 172 */,
	171/* [LT_1 tvm tvi] -> compare 171 */,
	170/* [GT_1 tvi tvm] -> compare 170 */,
	169/* [GT_1 tvm tvi] -> compare 169 */,
	168/* [NE_1 tvi tvm] -> compare 168 */,
	167/* [NE_1 tvm tvi] -> compare 167 */,
	166/* [EQ_1 tvi tvm] -> compare 166 */,
	165/* [EQ_1 tvm tvi] -> compare 165 */,
	164/* [LEU_4 tvi tvm] -> compare 164 */,
	163/* [LEU_4 tvm tvi] -> compare 163 */,
	162/* [GEU_4 tvi tvm] -> compare 162 */,
	161/* [GEU_4 tvm tvi] -> compare 161 */,
	160/* [LTU_4 tvi tvm] -> compare 160 */,
	159/* [LTU_4 tvm tvi] -> compare 159 */,
	158/* [GTU_4 tvi tvm] -> compare 158 */,
	157/* [GTU_4 tvm tvi] -> compare 157 */,
	156/* [LE_4 tvi tvm] -> compare 156 */,
	155/* [LE_4 tvm tvi] -> compare 155 */,
	154/* [GE_4 tvi tvm] -> compare 154 */,
	153/* [GE_4 tvm tvi] -> compare 153 */,
	152/* [LT_4 tvi tvm] -> compare 152 */,
	151/* [LT_4 tvm tvi] -> compare 151 */,
	150/* [GT_4 tvi tvm] -> compare 150 */,
	149/* [GT_4 tvm tvi] -> compare 149 */,
	148/* [NE_4 tvi tvm] -> compare 148 */,
	147/* [NE_4 tvm tvi] -> compare 147 */,
	146/* [EQ_4 tvi tvm] -> compare 146 */,
	145/* [EQ_4 tvm tvi] -> compare 145 */,
	144/* [LEU_8 tvi tvm] -> compare 144 */,
	143/* [LEU_8 tvm tvi] -> compare 143 */,
	142/* [GEU_8 tvi tvm] -> compare 142 */,
	141/* [GEU_8 tvm tvi] -> compare 141 */,
	140/* [LTU_8 tvi tvm] -> compare 140 */,
	139/* [LTU_8 tvm tvi] -> compare 139 */,
	138/* [GTU_8 tvi tvm] -> compare 138 */,
	137/* [GTU_8 tvm tvi] -> compare 137 */,
	136/* [LE_8 tvi tvm] -> compare 136 */,
	135/* [LE_8 tvm tvi] -> compare 135 */,
	134/* [GE_8 tvi tvm] -> compare 134 */,
	133/* [GE_8 tvm tvi] -> compare 133 */,
	132/* [LT_8 tvi tvm] -> compare 132 */,
	131/* [LT_8 tvm tvi] -> compare 131 */,
	130/* [GT_8 tvi tvm] -> compare 130 */,
	129/* [GT_8 tvm tvi] -> compare 129 */,
	128/* [NE_8 tvi tvm] -> compare 128 */,
	127/* [NE_8 tvm tvi] -> compare 127 */,
	126/* [EQ_8 tvi tvm] -> compare 126 */,
	125/* [EQ_8 tvm tvi] -> compare 125 */,
	92/* [COPY_1 tv mem] -> inst 92 */,
	91/* [COPY_4 tv mem] -> inst 91 */,
	90/* [COPY_8 tv mem] -> inst 90 */,
	89/* [COPY_1 tvm tvi] -> inst 89 */,
	88/* [COPY_4 tvm tvi] -> inst 88 */,
	87/* [COPY_8 tvm tvi] -> inst 87 */,
	84/* [CAST_CHECK_0 tv tvi] -> tv 84 */,
	62/* [LEA_8 tv addr] -> inst 62 */,
	57/* [SHAR_1 t tv] -> t 57 */,
	56/* [SHL_1 t tv] -> t 56 */,
	55/* [XOR_1 tvmi t] -> t 55 */,
	54/* [XOR_1 t tvmi] -> t 54 */,
	53/* [OR_1 tvmi t] -> t 53 */,
	52/* [OR_1 t tvmi] -> t 52 */,
	51/* [AND_1 tvmi t] -> t 51 */,
	50/* [AND_1 t tvmi] -> t 50 */,
	49/* [MOD_1 t tvm] -> t 49 */,
	48/* [DIV_1 t tvm] -> t 48 */,
	47/* [MUL_1 immed tvm] -> t 47 */,
	46/* [MUL_1 tvm immed] -> t 46 */,
	45/* [MUL_1 tvmi t] -> t 45 */,
	44/* [MUL_1 t tvmi] -> t 44 */,
	43/* [SUB_1 t tvmi] -> t 43 */,
	42/* [ADD_1 tvmi t] -> t 42 */,
	41/* [ADD_1 t tvmi] -> t 41 */,
	38/* [SHAR_4 t tv] -> t 38 */,
	37/* [SHL_4 t tv] -> t 37 */,
	36/* [XOR_4 tvmi t] -> t 36 */,
	35/* [XOR_4 t tvmi] -> t 35 */,
	34/* [OR_4 tvmi t] -> t 34 */,
	33/* [OR_4 t tvmi] -> t 33 */,
	32/* [AND_4 tvmi t] -> t 32 */,
	31/* [AND_4 t tvmi] -> t 31 */,
	30/* [MOD_4 t tvm] -> t 30 */,
	29/* [DIV_4 t tvm] -> t 29 */,
	28/* [MUL_4 immed tvm] -> t 28 */,
	27/* [MUL_4 tvm immed] -> t 27 */,
	26/* [MUL_4 tvmi t] -> t 26 */,
	25/* [MUL_4 t tvmi] -> t 25 */,
	24/* [SUB_4 t tvmi] -> t 24 */,
	23/* [ADD_4 tvmi t] -> t 23 */,
	22/* [ADD_4 t tvmi] -> t 22 */,
	19/* [SHAR_8 t tv] -> t 19 */,
	18/* [SHL_8 t tv] -> t 18 */,
	17/* [XOR_8 tvmi t] -> t 17 */,
	16/* [XOR_8 t tvmi] -> t 16 */,
	15/* [OR_8 tvmi t] -> t 15 */,
	14/* [OR_8 t tvmi] -> t 14 */,
	13/* [AND_8 tvmi t] -> t 13 */,
	12/* [AND_8 t tvmi] -> t 12 */,
	11/* [MOD_8 t tvm] -> t 11 */,
	10/* [DIV_8 t tvm] -> t 10 */,
	9/* [MUL_8 immed tvm] -> t 9 */,
	8/* [MUL_8 tvm immed] -> t 8 */,
	7/* [MUL_8 tvmi t] -> t 7 */,
	6/* [MUL_8 t tvmi] -> t 6 */,
	5/* [SUB_8 t tvmi] -> t 5 */,
	4/* [ADD_8 tvmi t] -> t 4 */,
	3/* [ADD_8 t tvmi] -> t 3 */,
	2/* [LIST_0 inst inst] -> inst 2 */:
		result = new ITree[2];
		result[0] = p.getLeft();
		result[1] = p.getRight();

	case
	323/* [THROW_8 t] -> inst 323 */,
	320/* [DYNAMIC_CALL_0 t] -> inst 320 */,
	318/* [STATIC_CALL_0 t] -> inst 318 */,
	317/* [PROC_CALL_DISCARD_0 t] -> inst 317 */,
	304/* [THROW_RETURN_8 tv] -> inst 304 */,
	258/* [RESULT_8 t] -> param 258 */,
	242/* [INDIRECT_1 addr] -> mem 242 */,
	241/* [INDIRECT_4 addr] -> mem 241 */,
	240/* [INDIRECT_8 addr] -> mem 240 */,
	216/* [RESULT_F_0 t] -> inst 216 */,
	215/* [RESULT_8 t] -> inst 215 */,
	210/* [BOX_0 t] -> t 210 */,
	208/* [BRANCHNZ_1 tvm] -> inst 208 */,
	207/* [BRANCHZ_1 tvm] -> inst 207 */,
	206/* [BRANCHNZ_4 tvm] -> inst 206 */,
	205/* [BRANCHZ_4 tvm] -> inst 205 */,
	204/* [BRANCHNZ_8 tvm] -> inst 204 */,
	203/* [BRANCHZ_8 tvm] -> inst 203 */,
	201/* [BRANCHNZ_1 immed] -> inst 201 */,
	200/* [BRANCHNZ_1 immed] -> inst 200 */,
	199/* [BRANCHZ_1 immed] -> inst 199 */,
	198/* [BRANCHZ_1 immed] -> inst 198 */,
	197/* [BRANCHNZ_4 immed] -> inst 197 */,
	196/* [BRANCHNZ_4 immed] -> inst 196 */,
	195/* [BRANCHZ_4 immed] -> inst 195 */,
	194/* [BRANCHZ_4 immed] -> inst 194 */,
	193/* [BRANCHNZ_8 immed] -> inst 193 */,
	192/* [BRANCHNZ_8 immed] -> inst 192 */,
	191/* [BRANCHZ_8 immed] -> inst 191 */,
	190/* [BRANCHZ_8 immed] -> inst 190 */,
	189/* [BRANCH_0 immed] -> inst 189 */,
	188/* [BRANCH_0 immed] -> inst 188 */,
	187/* [BRANCH_0 compare] -> inst 187 */,
	186/* [DECBNN_8 tvm] -> inst 186 */,
	94/* [POP_8 tvm] -> inst 94 */,
	93/* [PUSH_8 tvmi] -> inst 93 */,
	83/* [TREAT_AS_1 tvm] -> tvm 83 */,
	82/* [TREAT_AS_4 tvm] -> tvm 82 */,
	81/* [TREAT_AS_8 tvm] -> tvm 81 */,
	80/* [CAST_FROM8_1 t] -> t 80 */,
	79/* [CAST_FROM8_1 mem] -> mem 79 */,
	78/* [CAST_FROM8_1 immed] -> immed 78 */,
	77/* [CAST_FROM8_4 t] -> t 77 */,
	76/* [CAST_FROM8_4 mem] -> mem 76 */,
	75/* [CAST_FROM8_4 immed] -> immed 75 */,
	74/* [CAST_FROM4_1 t] -> t 74 */,
	73/* [CAST_FROM4_1 mem] -> mem 73 */,
	72/* [CAST_FROM4_1 immed] -> immed 72 */,
	71/* [CAST_FROM4_8 tvm] -> tv 71 */,
	70/* [CAST_FROM4_8 immed] -> immed 70 */,
	69/* [CAST_FROM1_4 tvm] -> tv 69 */,
	68/* [CAST_FROM1_4 immed] -> immed 68 */,
	67/* [CAST_FROM1_8 tvm] -> tv 67 */,
	66/* [CAST_FROM1_8 immed] -> immed 66 */,
	65/* [CAST_FROM4_4 mem] -> mem 65 */,
	64/* [CAST_FROM4_4 tv] -> tv 64 */,
	63/* [CAST_FROM4_4 immed] -> immed 63 */,
	59/* [NOT_1 t] -> t 59 */,
	58/* [NEG_1 t] -> t 58 */,
	40/* [NOT_4 t] -> t 40 */,
	39/* [NEG_4 t] -> t 39 */,
	21/* [NOT_8 t] -> t 21 */,
	20/* [NEG_8 t] -> t 20 */:
		result = new ITree[1];
		result[0] = p.getLeft();

	case
	291/* index -> addr 291 */,
	290/* base -> addr 290 */,
	287/* tv -> index 287 */,
	284/* const -> base 284 */,
	283/* tv -> base 283 */,
	280/* tv -> inst 280 */,
	279/* immed -> tvi 279 */,
	278/* tv -> tvi 278 */,
	277/* v -> tv 277 */,
	276/* t -> tv 276 */,
	275/* immed -> tvmi 275 */,
	274/* tvm -> tvmi 274 */,
	273/* tv -> tvm 273 */,
	272/* mem -> tvm 272 */,
	259/* param -> inst 259 */,
	250/* arg -> inst 250 */,
	185/* compare -> t 185 */,
	61/* addr -> t 61 */,
	60/* tvmi -> t 60 */:
		result = new ITree[1];
		result[0] = p;

	case
	86/* [OBJ_NE_0 [PAIR_8 tv tv] tv] -> inst 86 */,
	85/* [OBJ_EQ_0 [PAIR_8 tv tv] tv] -> inst 85 */:
		result = new ITree[3];
		result[0] = p.getLeft().getLeft();
		result[1] = p.getLeft().getRight();
		result[2] = p.getRight();

	case
	124/* [COPY_1 tv [MUL_1 tvmi tv]] -> inst 124 */,
	123/* [COPY_1 tv [MUL_1 tv tvmi]] -> inst 123 */,
	122/* [COPY_1 tvm [SUB_1 tvi tvm]] -> inst 122 */,
	121/* [COPY_1 tvm [SUB_1 tvm tvi]] -> inst 121 */,
	120/* [COPY_1 tvm [OR_1 tvi tvm]] -> inst 120 */,
	119/* [COPY_1 tvm [OR_1 tvm tvi]] -> inst 119 */,
	118/* [COPY_1 tvm [AND_1 tvi tvm]] -> inst 118 */,
	117/* [COPY_1 tvm [AND_1 tvm tvi]] -> inst 117 */,
	116/* [COPY_1 tvm [ADD_1 tvi tvm]] -> inst 116 */,
	115/* [COPY_1 tvm [ADD_1 tvm tvi]] -> inst 115 */,
	114/* [COPY_4 tv [MUL_4 tvmi tv]] -> inst 114 */,
	113/* [COPY_4 tv [MUL_4 tv tvmi]] -> inst 113 */,
	112/* [COPY_4 tvm [SUB_4 tvi tvm]] -> inst 112 */,
	111/* [COPY_4 tvm [SUB_4 tvm tvi]] -> inst 111 */,
	110/* [COPY_4 tvm [OR_4 tvi tvm]] -> inst 110 */,
	109/* [COPY_4 tvm [OR_4 tvm tvi]] -> inst 109 */,
	108/* [COPY_4 tvm [AND_4 tvi tvm]] -> inst 108 */,
	107/* [COPY_4 tvm [AND_4 tvm tvi]] -> inst 107 */,
	106/* [COPY_4 tvm [ADD_4 tvi tvm]] -> inst 106 */,
	105/* [COPY_4 tvm [ADD_4 tvm tvi]] -> inst 105 */,
	104/* [COPY_8 tv [MUL_8 tvmi tv]] -> inst 104 */,
	103/* [COPY_8 tv [MUL_8 tv tvmi]] -> inst 103 */,
	102/* [COPY_8 tvm [SUB_8 tvi tvm]] -> inst 102 */,
	101/* [COPY_8 tvm [SUB_8 tvm tvi]] -> inst 101 */,
	100/* [COPY_8 tvm [OR_8 tvi tvm]] -> inst 100 */,
	99/* [COPY_8 tvm [OR_8 tvm tvi]] -> inst 99 */,
	98/* [COPY_8 tvm [AND_8 tvi tvm]] -> inst 98 */,
	97/* [COPY_8 tvm [AND_8 tvm tvi]] -> inst 97 */,
	96/* [COPY_8 tvm [ADD_8 tvi tvm]] -> inst 96 */,
	95/* [COPY_8 tvm [ADD_8 tvm tvi]] -> inst 95 */:
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
		return new ITree(0,Op.COMMENT_0,0,node.getValue());

	}
}
class ITreeFactory2 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,(children[0]),(children[1]));

	}
}
class ITreeFactory3 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.ADD2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory4 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.ADD2,8,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory5 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.SUB2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory6 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.MUL2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory7 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.MUL2,8,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory8 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.MUL,8,(children[0]),(children[1]))),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory9 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.MUL,8,(children[1]),(children[0]))),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory10 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.DIV,8,new ITree(0,Op.PAIR,8,(children[0]),(children[1])),new ITree(0,Op.TEMP,8,temp_t)),(children[0]).getTemp());

	}
}
class ITreeFactory11 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.MOD,8,new ITree(0,Op.PAIR,8,new ITree(0,Op.TEMP,8,temp_t),(children[0])),(children[1])),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory12 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.AND2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory13 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.AND2,8,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory14 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.OR2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory15 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.OR2,8,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory16 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.XOR2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory17 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.XOR2,8,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory18 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.SHL2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory19 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.SHAR2,8,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory20 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.NEG2,8,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory21 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.NOT2,8,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory22 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.ADD2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory23 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.ADD2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory24 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.SUB2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory25 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.MUL2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory26 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.MUL2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory27 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.MUL,4,(children[0]),(children[1]))),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory28 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.COPY,4,new ITree(0,Op.TEMP,4,temp_t),new ITree(0,Op.MUL,4,(children[1]),(children[0]))),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory29 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.DIV,4,new ITree(0,Op.PAIR,4,(children[0]),(children[1])),new ITree(0,Op.TEMP,4,temp_t)),(children[0]).getTemp());

	}
}
class ITreeFactory30 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.MOD,4,new ITree(0,Op.PAIR,4,new ITree(0,Op.TEMP,4,temp_t),(children[0])),(children[1])),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory31 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.AND2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory32 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.AND2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory33 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.OR2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory34 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.OR2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory35 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.XOR2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory36 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.XOR2,4,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory37 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.SHL2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory38 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.SHAR2,4,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory39 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.NEG2,4,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory40 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.NOT2,4,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory41 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.ADD2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory42 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.ADD2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory43 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.SUB2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory44 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.MUL2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory45 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.MUL2,1,(children[1]),(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory46 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.COPY,1,new ITree(0,Op.TEMP,1,temp_t),new ITree(0,Op.MUL,1,(children[0]),(children[1]))),new ITree(0,Op.TEMP,1,temp_t));

	}
}
class ITreeFactory47 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.COPY,1,new ITree(0,Op.TEMP,1,temp_t),new ITree(0,Op.MUL,1,(children[1]),(children[0]))),new ITree(0,Op.TEMP,1,temp_t));

	}
}
class ITreeFactory48 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.DIV,1,new ITree(0,Op.PAIR,1,(children[0]),(children[1])),new ITree(0,Op.TEMP,1,temp_t)),(children[0]).getTemp());

	}
}
class ITreeFactory49 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.MOD,1,new ITree(0,Op.PAIR,1,new ITree(0,Op.TEMP,1,temp_t),(children[0])),(children[1])),new ITree(0,Op.TEMP,1,temp_t));

	}
}
class ITreeFactory50 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.AND2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory51 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.AND2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory52 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.OR2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory53 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.OR2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory54 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.XOR2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory55 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.XOR2,1,(children[1]),(children[0])),(children[1]).getTemp());

	}
}
class ITreeFactory56 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.SHL2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory57 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.SHAR2,1,(children[0]),(children[1])),(children[0]).getTemp());

	}
}
class ITreeFactory58 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.NEG2,1,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory59 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.NOT2,1,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory60 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
            int size = children[0].getSize(); int temp_t = Gen.TempFactory.nextTemp(); return new ITree(0,Op.SEQ,size,new ITree(0,Op.COPY,size,new ITree(0,Op.TEMP,size,temp_t),(children[0])),new ITree(0,Op.TEMP,size,temp_t)); ;

	}
}
class ITreeFactory61 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LEA,8,new ITree(0,Op.TEMP,8,temp_t),(children[0])),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory62 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LEA,8,(children[0]),(children[1]));

	}
}
class ITreeFactory63 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory64 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory65 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory66 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory67 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.CAST_FROM1,8,new ITree(0,Op.TEMP,8,temp_t),(children[0])),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory68 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory69 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.CAST_FROM1,4,new ITree(0,Op.TEMP,4,temp_t),(children[0])),new ITree(0,Op.TEMP,4,temp_t));

	}
}
class ITreeFactory70 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory71 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.CAST_FROM4,8,new ITree(0,Op.TEMP,8,temp_t),(children[0])),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory72 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory73 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory74 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.TREAT_AS_1,1,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory75 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory76 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory77 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,new ITree(0,Op.TREAT_AS_8,8,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory78 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory79 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory80 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,new ITree(0,Op.TREAT_AS_1,1,(children[0])),(children[0]).getTemp());

	}
}
class ITreeFactory81 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory82 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory83 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory84 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
	int temp_m = Gen.TempFactory.nextLabelNumber();
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),(children[0])),new ITree(0,Op.BRANCHZ,8,new ITree(0,Op.TEMP,8,temp_t),".L"+temp_m).rewrite(),new ITree(0,Op.LABEL,0,".L"+temp_l),new ITree(0,Op.BRANCH,0,new ITree(0,Op.EQ,8,new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,0),new ITree(0,Op.TEMP,8,temp_t))),(children[1])),".L"+temp_m).rewrite(),new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,0),new ITree(0,Op.TEMP,8,temp_t)))),new ITree(0,Op.BRANCHNZ,8,new ITree(0,Op.TEMP,8,temp_t),".L"+temp_l).rewrite(),new ITree(0,Op.CALL,0,"__throw_castexception"),new ITree(0,Op.LABEL,0,".L"+temp_m)),(children[0]).getTemp());

	}
}
class ITreeFactory85 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY_8,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP_8,8,(children[0]),(children[1]))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,1)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_t),node.getString()),new ITree(0,Op.COPY_8,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CMP_8,8,(children[0]),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,0)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_u),node.getString()),new ITree(0,Op.COPY_8,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CMP_8,8,(children[1]),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_u),node.getString()));

	}
}
class ITreeFactory86 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY_8,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP_8,8,(children[0]),(children[1]))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,0)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_t),node.getString()),new ITree(0,Op.COPY_8,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CMP_8,8,(children[0]),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.COPY_1,1,(children[2]),new ITree(0,Op.CONST,1,1)),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_u),node.getString()),new ITree(0,Op.COPY_8,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CMP_8,8,(children[1]),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_u),node.getString()));

	}
}
class ITreeFactory87 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_8,8,(children[0]),(children[1]));

	}
}
class ITreeFactory88 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_4,4,(children[0]),(children[1]));

	}
}
class ITreeFactory89 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_1,1,(children[0]),(children[1]));

	}
}
class ITreeFactory90 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_8,8,(children[0]),(children[1]));

	}
}
class ITreeFactory91 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_4,4,(children[0]),(children[1]));

	}
}
class ITreeFactory92 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY_1,1,(children[0]),(children[1]));

	}
}
class ITreeFactory93 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PUSH_8,8,(children[0]));

	}
}
class ITreeFactory94 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.POP_8,8,(children[0]));

	}
}
class ITreeFactory95 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,8,(children[1]),(children[2]));

	}
}
class ITreeFactory96 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,8,(children[2]),(children[1]));

	}
}
class ITreeFactory97 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2,8,(children[1]),(children[2]));

	}
}
class ITreeFactory98 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2,8,(children[2]),(children[1]));

	}
}
class ITreeFactory99 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2,8,(children[1]),(children[2]));

	}
}
class ITreeFactory100 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2,8,(children[2]),(children[1]));

	}
}
class ITreeFactory101 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUB2,8,(children[1]),(children[2]));

	}
}
class ITreeFactory102 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUBR2,8,(children[2]),(children[1]));

	}
}
class ITreeFactory103 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2,8,(children[1]),(children[2]));

	}
}
class ITreeFactory104 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2,8,(children[2]),(children[1]));

	}
}
class ITreeFactory105 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,4,(children[1]),(children[2]));

	}
}
class ITreeFactory106 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,4,(children[2]),(children[1]));

	}
}
class ITreeFactory107 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2,4,(children[1]),(children[2]));

	}
}
class ITreeFactory108 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2,4,(children[2]),(children[1]));

	}
}
class ITreeFactory109 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2,4,(children[1]),(children[2]));

	}
}
class ITreeFactory110 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2,4,(children[2]),(children[1]));

	}
}
class ITreeFactory111 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUB2,4,(children[1]),(children[2]));

	}
}
class ITreeFactory112 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUBR2,4,(children[2]),(children[1]));

	}
}
class ITreeFactory113 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2,4,(children[1]),(children[2]));

	}
}
class ITreeFactory114 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2,4,(children[2]),(children[1]));

	}
}
class ITreeFactory115 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,1,(children[1]),(children[2]));

	}
}
class ITreeFactory116 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,1,(children[2]),(children[1]));

	}
}
class ITreeFactory117 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2,1,(children[1]),(children[2]));

	}
}
class ITreeFactory118 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.AND2,1,(children[2]),(children[1]));

	}
}
class ITreeFactory119 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2,1,(children[1]),(children[2]));

	}
}
class ITreeFactory120 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.OR2,1,(children[2]),(children[1]));

	}
}
class ITreeFactory121 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUB2,1,(children[1]),(children[2]));

	}
}
class ITreeFactory122 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUBR2,1,(children[2]),(children[1]));

	}
}
class ITreeFactory123 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2,1,(children[1]),(children[2]));

	}
}
class ITreeFactory124 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL2,1,(children[2]),(children[1]));

	}
}
class ITreeFactory125 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory126 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory127 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JNE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory128 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JNE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory129 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JG)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory130 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JL)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory131 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JL)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory132 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JG)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory133 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JGE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory134 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JLE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory135 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JLE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory136 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JGE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory137 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JGU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory138 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JLU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory139 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JLU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory140 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JGU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory141 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JGEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory142 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JLEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory143 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),(children[1]),Op.JLEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory144 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[1]),(children[0]),Op.JGEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory145 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory146 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory147 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JNE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory148 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JNE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory149 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JG)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory150 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JL)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory151 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JL)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory152 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JG)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory153 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JGE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory154 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JLE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory155 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JLE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory156 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JGE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory157 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JGU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory158 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JLU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory159 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JLU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory160 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JGU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory161 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JGEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory162 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JLEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory163 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),(children[1]),Op.JLEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory164 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[1]),(children[0]),Op.JGEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory165 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory166 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory167 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JNE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory168 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JNE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory169 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JG)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory170 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JL)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory171 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JL)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory172 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JG)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory173 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JGE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory174 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JLE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory175 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JLE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory176 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JGE)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory177 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JGU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory178 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JLU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory179 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JLU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory180 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JGU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory181 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JGEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory182 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JLEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory183 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),(children[1]),Op.JLEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory184 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[1]),(children[0]),Op.JGEU)),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory185 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,children[0].getLeft().getRight().getInt()-Op.JE+Op.SETE_1,1,new ITree(0,Op.TEMP,1,temp_t),(children[0])),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory186 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DECBNN_8,8,(children[0]),node.getString());

	}
}
class ITreeFactory187 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,(children[0]).getLeft().getRight().getInt(),0,(children[0]),node.getString());

	}
}
class ITreeFactory188 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory189 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT,0,"dead branch");

	}
}
class ITreeFactory190 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT,0,"dead branch");

	}
}
class ITreeFactory191 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory192 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory193 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT,0,"dead branch");

	}
}
class ITreeFactory194 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT,0,"dead branch");

	}
}
class ITreeFactory195 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory196 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory197 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT,0,"dead branch");

	}
}
class ITreeFactory198 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT,0,"dead branch");

	}
}
class ITreeFactory199 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory200 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory201 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT,0,"dead branch");

	}
}
class ITreeFactory202 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.UNWIND,0),new ITree(0,Op.DEFINT,8,".L"+temp_l),new ITree(0,Op.DEFINT,8,node.getString()),new ITree(0,Op.POPSEG,0),new ITree(0,Op.LINE,0,node.getString()));

	}
}
class ITreeFactory203 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JE,0,new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP_8,8,(children[0]),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.TEMP,8,temp_t)),node.getString());

	}
}
class ITreeFactory204 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JNE,0,new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP_8,8,(children[0]),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.TEMP,8,temp_t)),node.getString());

	}
}
class ITreeFactory205 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JE,0,new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.TEMP,8,temp_t)),node.getString());

	}
}
class ITreeFactory206 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JNE,0,new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,4,(children[0]),new ITree(0,Op.CONST,4,0))),new ITree(0,Op.TEMP,8,temp_t)),node.getString());

	}
}
class ITreeFactory207 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JE,0,new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),new ITree(0,Op.CONST,1,0))),new ITree(0,Op.TEMP,8,temp_t)),node.getString());

	}
}
class ITreeFactory208 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.JNE,0,new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,1,(children[0]),new ITree(0,Op.CONST,1,0))),new ITree(0,Op.TEMP,8,temp_t)),node.getString());

	}
}
class ITreeFactory209 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.JUMP,0,node.getString());

	}
}
class ITreeFactory210 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.ARG0,8,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")),new ITree(0,Op.CALL,0,new ITree(0,Op.TEMP,8,temp_t),"box$integer")),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory211 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
	int temp_m = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.RODATA,0),new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.CONST_CSTR,0,node.getString()),new ITree(0,Op.DLABEL,0,".L"+temp_m),new ITree(0,Op.DEFINT,8," __ctable_N6System6StringE+24"),new ITree(0,Op.DEFINT,8,".L"+temp_l),new ITree(0,Op.DEFINT,8,node.getString().getLength()),new ITree(0,Op.POPSEG,0)),new ITree(0,Op.INDIRECT,8, new ITree(0,Op.LABEL,0,".L"+temp_m + "@GOTPCREL(%rip)") ));

	}
}
class ITreeFactory212 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
	int temp_m = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.RODATA,0),new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.CONST_CSTR,0,node.getString()),new ITree(0,Op.DLABEL,0,".L"+temp_m),new ITree(0,Op.DEFINT,8," __ctable_N6System6StringE+24"),new ITree(0,Op.DEFINT,8,".L"+temp_l),new ITree(0,Op.DEFINT,8,node.getString().getLength()),new ITree(0,Op.POPSEG,0)),new ITree(0,Op.GLOBAL,8,".L"+temp_m));

	}
}
class ITreeFactory213 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.RODATA,0),new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.CONST_CSTR,0,node.getString()),new ITree(0,Op.POPSEG,0)),new ITree(0,Op.INDIRECT,8, new ITree(0,Op.LABEL,0,".L"+temp_l + "@GOTPCREL(%rip)") ));

	}
}
class ITreeFactory214 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.PUSHSEG,0),new ITree(0,Op.RODATA,0),new ITree(0,Op.DLABEL,0,".L"+temp_l),new ITree(0,Op.CONST_CSTR,0,node.getString()),new ITree(0,Op.POPSEG,0)),new ITree(0,Op.GLOBAL,8,".L"+temp_l));

	}
}
class ITreeFactory215 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.RESULT,8,(children[0])),new ITree(0,Op.JUMP,0,node.getString()));

	}
}
class ITreeFactory216 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.RESULT,8,(children[0])));

	}
}
class ITreeFactory217 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PUSH,8,new ITree(0,Op.REGISTER,8,7));

	}
}
class ITreeFactory218 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PUSHSEG_0,0,node.getValue());

	}
}
class ITreeFactory219 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.POPSEG_0,0,node.getValue());

	}
}
class ITreeFactory220 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.STATIC_0,0,node.getValue());

	}
}
class ITreeFactory221 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEXT_0,0,node.getValue());

	}
}
class ITreeFactory222 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DATA_0,0,node.getValue());

	}
}
class ITreeFactory223 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RODATA_0,0,node.getValue());

	}
}
class ITreeFactory224 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COMMENT,0,"try block completed without encountering exception. Excecute finally and continue"),new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CONST,8,"0")),new ITree(0,Op.ARG0,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.COMMENT,0,"finally")));

	}
}
class ITreeFactory225 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COMMENT,0,"exception handled - throw a stop exception to outer handler"),new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CONST,8,"0")),new ITree(0,Op.ARG0,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.COMMENT,0,"finally")),new ITree(0,Op.JUMP,0,node.getString()));

	}
}
class ITreeFactory226 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.ARG0,8,(children[0]).getTemp(),new ITree(0,Op.ARG1,8,(children[1]),new ITree(0,Op.COMMENT,0,"conditional rethrow"))),new ITree(0,Op.COMMENT,0,"exception not handled - throw unhandled exception to outer handler"),new ITree(0,Op.JNE,0,new ITree(0,Op.TEMP,8,temp_t),node.getString()),new ITree(0,Op.COMMENT,0,"exception handled - fall through to enclosing code"));

	}
}
class ITreeFactory227 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CMP,8,(children[0]),new ITree(0,Op.CONST,8,3))),new ITree(0,Op.RESULT,8,(children[1])),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_t),node.getString()),new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CMP,8,(children[0]).getTemp(),new ITree(0,Op.CONST,8,0))),new ITree(0,Op.JE,0,new ITree(0,Op.TEMP,8,temp_u),".L"+temp_l),new ITree(0,Op.ARG0,8,(children[0]).getTemp(),new ITree(0,Op.ARG1,8,(children[1]).getTemp(),new ITree(0,Op.COMMENT,0,"conditional rethrow"))),new ITree(0,Op.CALL,0,"__throw_endfinally"),new ITree(0,Op.LABEL,0,".L"+temp_l));

	}
}
class ITreeFactory228 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COPY,8,new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,20),new ITree(0,Op.REGISTER,8,8))),new ITree(0,Op.CONST,8,"-1"));

	}
}
class ITreeFactory229 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory230 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory231 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CONST_8,8,node.getValue());

	}
}
class ITreeFactory232 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LABEL_0,0,node.getValue());

	}
}
class ITreeFactory233 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DLABEL_0,0,node.getValue());

	}
}
class ITreeFactory234 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory235 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory236 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CONST_8,8,node.getValue());

	}
}
class ITreeFactory237 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CONST_4,4,node.getValue());

	}
}
class ITreeFactory238 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CONST_1,1,node.getValue());

	}
}
class ITreeFactory239 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory240 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.INDIRECT_8,8,(children[0]),node.getValue());

	}
}
class ITreeFactory241 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.INDIRECT_4,4,(children[0]),node.getValue());

	}
}
class ITreeFactory242 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.INDIRECT_1,1,(children[0]),node.getValue());

	}
}
class ITreeFactory243 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP_8,8,node.getValue());

	}
}
class ITreeFactory244 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP_4,4,node.getValue());

	}
}
class ITreeFactory245 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP_1,1,node.getValue());

	}
}
class ITreeFactory246 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.REGISTER_8,8,node.getValue());

	}
}
class ITreeFactory247 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.REGISTER_4,4,node.getValue());

	}
}
class ITreeFactory248 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.REGISTER_1,1,node.getValue());

	}
}
class ITreeFactory249 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT_0,0,node.getValue());

	}
}
class ITreeFactory250 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory251 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG0_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory252 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG1_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory253 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG2_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory254 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG3_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory255 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG4_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory256 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ARG5_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory257 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.COMMENT_0,0,node.getValue());

	}
}
class ITreeFactory258 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RESULT_8,8,(children[0]),node.getValue());

	}
}
class ITreeFactory259 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory260 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM0_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory261 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM1_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory262 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM2_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory263 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM3_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory264 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM4_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory265 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.PARAM5_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory266 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,8,(children[0]),(children[1]));

	}
}
class ITreeFactory267 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,4,(children[0]),(children[1]));

	}
}
class ITreeFactory268 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SEQ,1,(children[0]),(children[1]));

	}
}
class ITreeFactory269 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP,8,node.getInt());

	}
}
class ITreeFactory270 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP,4,node.getInt());

	}
}
class ITreeFactory271 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.TEMP,1,node.getInt());

	}
}
class ITreeFactory272 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory273 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory274 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory275 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory276 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory277 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory278 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory279 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory280 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory281 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,8,(children[0]),(children[1]));

	}
}
class ITreeFactory282 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,8,(children[1]),(children[0]));

	}
}
class ITreeFactory283 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,"0"),(children[0]));

	}
}
class ITreeFactory284 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory285 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL,8,(children[0]),(children[1]));

	}
}
class ITreeFactory286 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL,8,(children[1]),(children[0]));

	}
}
class ITreeFactory287 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.MUL,8,(children[0]),new ITree(0,Op.CONST,8,"1"));

	}
}
class ITreeFactory288 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD_8,8,(children[0]),(children[1]),node.getValue());

	}
}
class ITreeFactory289 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,8,(children[1]),(children[0]));

	}
}
class ITreeFactory290 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory291 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return (children[0]);

	}
}
class ITreeFactory292 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,(node.getValue())),new ITree(0,Op.REGISTER,8,7));

	}
}
class ITreeFactory293 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,(node.getValue())),new ITree(0,Op.REGISTER,8,7));

	}
}
class ITreeFactory294 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,(node.getValue())),new ITree(0,Op.REGISTER,8,7));

	}
}
class ITreeFactory295 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ENTER_0,0,node.getValue());

	}
}
class ITreeFactory296 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LEAVE_0,0,node.getValue());

	}
}
class ITreeFactory297 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LABEL_0,0,node.getValue());

	}
}
class ITreeFactory298 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DLABEL_0,0,node.getValue());

	}
}
class ITreeFactory299 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.EXTERN_0,0,node.getValue());

	}
}
class ITreeFactory300 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SAVE_ALL_0,0,node.getValue());

	}
}
class ITreeFactory301 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RESTORE_ALL_0,0,node.getValue());

	}
}
class ITreeFactory302 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.SUB2,8,new ITree(0,Op.REGISTER,8,8),new ITree(0,Op.CONST,8,node.getString()));

	}
}
class ITreeFactory303 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ADD2,8,new ITree(0,Op.REGISTER,8,8),new ITree(0,Op.CONST,8,node.getString()));

	}
}
class ITreeFactory304 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COMMENT,0,"throw return"),new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.CONST,8,"3")),new ITree(0,Op.ARG0,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.ARG1,8,(children[0]),new ITree(0,Op.COMMENT,0,"throw return"))),new ITree(0,Op.JUMP,0,node.getValue()));

	}
}
class ITreeFactory305 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.RET_0,0,node.getValue());

	}
}
class ITreeFactory306 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.ENTER_LOOP_0,0,node.getValue());

	}
}
class ITreeFactory307 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LEAVE_LOOP_0,0,node.getValue());

	}
}
class ITreeFactory308 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_l = Gen.TempFactory.nextLabelNumber();
		return new ITree(0,Op.LIST,0,new ITree(0,Op.BRANCH,0,new ITree(0,Op.LTU,8,(children[1]),new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,"8"),(children[0])))),".L"+temp_l).rewrite(),new ITree(0,Op.CALL,0,"__throw_arrayboundsexception"),new ITree(0,Op.LABEL,0,".L"+temp_l));

	}
}
class ITreeFactory309 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.BRANCH,0,new ITree(0,Op.GEU,8,(children[1]),new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,"8"),(children[0])))),node.getString()).rewrite();

	}
}
class ITreeFactory310 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.LABEL,0,node.getString()),new ITree(0,Op.CALL,0,"__throw_arrayboundsexception"));

	}
}
class ITreeFactory311 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),(children[1])),new ITree(0,Op.ARG1,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.ARG0,8,(children[0]),new ITree(0,Op.COMMENT,0,"last arg"))),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,8,temp_u),"__alloc_object")),new ITree(0,Op.TEMP,8,temp_u));

	}
}
class ITreeFactory312 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_t),(children[1])),new ITree(0,Op.ARG1,8,new ITree(0,Op.TEMP,8,temp_t),new ITree(0,Op.ARG0,8,(children[0]),new ITree(0,Op.COMMENT,0,"last arg"))),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,8,temp_u),"__alloc_object_finalize")),new ITree(0,Op.TEMP,8,temp_u));

	}
}
class ITreeFactory313 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CONST,8,node.getString())),new ITree(0,Op.ARG2,8,(children[1]),new ITree(0,Op.ARG1,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.ARG0,8,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")))),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,8,temp_t),"allocago")),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory314 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CONST,8,node.getString())),new ITree(0,Op.ARG2,8,(children[1]),new ITree(0,Op.ARG1,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.ARG0,8,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")))),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,8,temp_t),"allocagn")),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory315 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
	int temp_t = Gen.TempFactory.nextTemp();
	int temp_u = Gen.TempFactory.nextTemp();
		return new ITree(0,Op.SEQ,8,new ITree(0,Op.COPY,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.CONST,8,32)),new ITree(0,Op.ARG0,8,new ITree(0,Op.TEMP,8,temp_u),new ITree(0,Op.COMMENT,0,"alloc proc ref")),new ITree(0,Op.STATIC_CALL,0,new ITree(0,Op.TEMP,8,temp_t),"GC_malloc"),new ITree(0,Op.TEMP,8,temp_t));

	}
}
class ITreeFactory316 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.RESULT,8,(children[0])),new ITree(0,Op.PROC_CALL,0,(children[0]).getTemp()),new ITree(0,Op.COPY,8,(children[1]).getTemp(),(children[0]).getTemp()));

	}
}
class ITreeFactory317 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.RESULT,8,(children[0])),new ITree(0,Op.PROC_CALL_DISCARD,0,(children[0]).getTemp()));

	}
}
class ITreeFactory318 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.STATIC_CALL,0,(children[0]).getTemp(),node.getString());

	}
}
class ITreeFactory319 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.STATIC_CALL_DISCARD,0,node.getString());

	}
}
class ITreeFactory320 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,(children[0]).getTemp(),new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,"0"),new ITree(0,Op.REGISTER,8,6)))),new ITree(0,Op.DYNAMIC_CALL,0,(children[0]).getTemp(),new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,node.getString()),(children[0]).getTemp()))));

	}
}
class ITreeFactory321 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.COPY,8,new ITree(0,Op.REGISTER,8,1),new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,"0"),new ITree(0,Op.REGISTER,8,6)))),new ITree(0,Op.DYNAMIC_CALL_DISCARD,0,new ITree(0,Op.INDIRECT,8,new ITree(0,Op.ADD,8,new ITree(0,Op.CONST,8,node.getString()),new ITree(0,Op.REGISTER,8,1)))));

	}
}
class ITreeFactory322 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.CALL,0,node.getString());

	}
}
class ITreeFactory323 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.LIST,0,new ITree(0,Op.ARG0,8,(children[0]),new ITree(0,Op.COMMENT,0,"last arg")),new ITree(0,Op.CALL,0,"__throw_exception"));

	}
}
class ITreeFactory324 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DUMMY_JUMP_0,0,node.getValue());

	}
}
class ITreeFactory325 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DEFINT_8,8,node.getValue());

	}
}
class ITreeFactory326 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DEFINT_4,4,node.getValue());

	}
}
class ITreeFactory327 extends ITreeFactory {
	void init() { super.init(); }
	ITree create(ITree node, ITree[] children) {
		return new ITree(0,Op.DEFINT_1,1,node.getValue());

	}
}
}
