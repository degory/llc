namespace Gen {

class State extends System.Object {
	public int[] cost;
	public int[] rule;
	void init() { super.init(); cost = new int[15]; rule = new int[15]; }
	System.String toString() {
		System.StringBuffer b = new System.StringBuffer();
		if( cost[Selector.inst_NT] < 32767 ) { b.append("inst"); b.append('/'); b.append(cost[Selector.inst_NT]); b.append('/'); b.append(rule[Selector.inst_NT]); b.append(' '); }
		if( cost[Selector.tm_NT] < 32767 ) { b.append("tm"); b.append('/'); b.append(cost[Selector.tm_NT]); b.append('/'); b.append(rule[Selector.tm_NT]); b.append(' '); }
		if( cost[Selector.const_NT] < 32767 ) { b.append("const"); b.append('/'); b.append(cost[Selector.const_NT]); b.append('/'); b.append(rule[Selector.const_NT]); b.append(' '); }
		if( cost[Selector.immed_NT] < 32767 ) { b.append("immed"); b.append('/'); b.append(cost[Selector.immed_NT]); b.append('/'); b.append(rule[Selector.immed_NT]); b.append(' '); }
		if( cost[Selector.addr_NT] < 32767 ) { b.append("addr"); b.append('/'); b.append(cost[Selector.addr_NT]); b.append('/'); b.append(rule[Selector.addr_NT]); b.append(' '); }
		if( cost[Selector.mem_NT] < 32767 ) { b.append("mem"); b.append('/'); b.append(cost[Selector.mem_NT]); b.append('/'); b.append(rule[Selector.mem_NT]); b.append(' '); }
		if( cost[Selector.t_NT] < 32767 ) { b.append("t"); b.append('/'); b.append(cost[Selector.t_NT]); b.append('/'); b.append(rule[Selector.t_NT]); b.append(' '); }
		if( cost[Selector.arg_NT] < 32767 ) { b.append("arg"); b.append('/'); b.append(cost[Selector.arg_NT]); b.append('/'); b.append(rule[Selector.arg_NT]); b.append(' '); }
		if( cost[Selector.param_NT] < 32767 ) { b.append("param"); b.append('/'); b.append(cost[Selector.param_NT]); b.append('/'); b.append(rule[Selector.param_NT]); b.append(' '); }
		if( cost[Selector.tmi_NT] < 32767 ) { b.append("tmi"); b.append('/'); b.append(cost[Selector.tmi_NT]); b.append('/'); b.append(rule[Selector.tmi_NT]); b.append(' '); }
		if( cost[Selector.ti_NT] < 32767 ) { b.append("ti"); b.append('/'); b.append(cost[Selector.ti_NT]); b.append('/'); b.append(rule[Selector.ti_NT]); b.append(' '); }
		if( cost[Selector.base_NT] < 32767 ) { b.append("base"); b.append('/'); b.append(cost[Selector.base_NT]); b.append('/'); b.append(rule[Selector.base_NT]); b.append(' '); }
		if( cost[Selector.index_NT] < 32767 ) { b.append("index"); b.append('/'); b.append(cost[Selector.index_NT]); b.append('/'); b.append(rule[Selector.index_NT]); b.append(' '); }
		if( cost[Selector.flags_NT] < 32767 ) { b.append("flags"); b.append('/'); b.append(cost[Selector.flags_NT]); b.append('/'); b.append(rule[Selector.flags_NT]); b.append(' '); }
	return b;
	}
}
class Selector {
public const int inst_NT = 1;
public const int tm_NT = 2;
public const int const_NT = 3;
public const int immed_NT = 4;
public const int addr_NT = 5;
public const int mem_NT = 6;
public const int t_NT = 7;
public const int arg_NT = 8;
public const int param_NT = 9;
public const int tmi_NT = 10;
public const int ti_NT = 11;
public const int base_NT = 12;
public const int index_NT = 13;
public const int flags_NT = 14;

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

int[][] nts;

int[] getNTS(int n) {
	return nts[n];
}

int[] decode_inst;
int[] decode_tm;
int[] decode_const;
int[] decode_immed;
int[] decode_addr;
int[] decode_mem;
int[] decode_t;
int[] decode_arg;
int[] decode_param;
int[] decode_tmi;
int[] decode_ti;
int[] decode_base;
int[] decode_index;
int[] decode_flags;
int rule( State state, int goalnt) {
	if( goalnt < 1 || goalnt > 14) throw new System.Exception("rule: bad goal nonterminal: " + goalnt );
	if( state == null ) return 0;
	int nts = state.rule[goalnt];
	switch( goalnt ) {
	case inst_NT:	return decode_inst[state.rule[inst_NT]];
	case tm_NT:	return decode_tm[state.rule[tm_NT]];
	case const_NT:	return decode_const[state.rule[const_NT]];
	case immed_NT:	return decode_immed[state.rule[immed_NT]];
	case addr_NT:	return decode_addr[state.rule[addr_NT]];
	case mem_NT:	return decode_mem[state.rule[mem_NT]];
	case t_NT:	return decode_t[state.rule[t_NT]];
	case arg_NT:	return decode_arg[state.rule[arg_NT]];
	case param_NT:	return decode_param[state.rule[param_NT]];
	case tmi_NT:	return decode_tmi[state.rule[tmi_NT]];
	case ti_NT:	return decode_ti[state.rule[ti_NT]];
	case base_NT:	return decode_base[state.rule[base_NT]];
	case index_NT:	return decode_index[state.rule[index_NT]];
	case flags_NT:	return decode_flags[state.rule[flags_NT]];
	default:
		throw new System.Exception("rule: bad goal nonterminal " + goalnt );

		return 0;
	}
}

System.String[] nts_name;


System.String getNameNTS(int n) {
	return nts_name[n];

}

MTreeFactory[] result;
MTree getResult( int ern, ITree node, MTree[] children ) {
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
6,
6,
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
13,
0,
1,
1,
1,
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
1,
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
4,
4,
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
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
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
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
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
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
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
7,
7,
7,
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
9,
0,
0,
0,
0,
0,
0,
0,
9,
0,
0,
0,
0,
0,
0,
0,
9,
0,
0,
0,
0,
0,
0,
0,
9,
0,
0,
0,
0,
0,
0,
0,
9,
0,
0,
0,
0,
0,
0,
0,
9,
0,
0,
0,
0,
0,
0,
0,
8,
0,
0,
0,
0,
0,
0,
0,
8,
0,
0,
0,
0,
0,
0,
0,
8,
0,
0,
0,
0,
0,
0,
0,
8,
0,
0,
0,
0,
0,
0,
0,
8,
0,
0,
0,
0,
0,
0,
0,
8,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
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
1,
1,
};
public static int getReWriteGoal(int terminal) { return rewrite_goal[terminal]; }
void init() {
	nts_0 = new int[0];
	nts_1 = new int { tm_NT,  };
	nts_2 = new int { inst_NT, const_NT,  };
	nts_3 = new int { inst_NT, immed_NT,  };
	nts_4 = new int { addr_NT,  };
	nts_5 = new int { arg_NT,  };
	nts_6 = new int { t_NT, arg_NT,  };
	nts_7 = new int { t_NT,  };
	nts_8 = new int { param_NT,  };
	nts_9 = new int { t_NT, param_NT,  };
	nts_10 = new int { mem_NT,  };
	nts_11 = new int { immed_NT,  };
	nts_12 = new int { inst_NT, t_NT,  };
	nts_13 = new int { tmi_NT,  };
	nts_14 = new int { const_NT,  };
	nts_15 = new int { const_NT, t_NT,  };
	nts_16 = new int { t_NT, const_NT,  };
	nts_17 = new int { base_NT, index_NT,  };
	nts_18 = new int { base_NT,  };
	nts_19 = new int { index_NT,  };
	nts_20 = new int { tm_NT, ti_NT,  };
	nts_21 = new int { t_NT, tm_NT,  };
	nts_22 = new int { t_NT, immed_NT,  };
	nts_23 = new int { t_NT, tm_NT, immed_NT,  };
	nts_24 = new int { tm_NT, t_NT,  };
	nts_25 = new int { t_NT, tm_NT, t_NT,  };
	nts_26 = new int { t_NT, t_NT, tm_NT,  };
	nts_27 = new int { flags_NT, tm_NT, ti_NT,  };
	nts_28 = new int { flags_NT, t_NT, tmi_NT,  };
	nts_29 = new int { flags_NT,  };
	nts_30 = new int { t_NT, flags_NT,  };
	nts_31 = new int { t_NT, tmi_NT,  };
	nts_32 = new int { t_NT, addr_NT,  };
	nts_33 = new int { inst_NT, inst_NT,  };
	nts = new int[] {
		null,	/* 0 */

		nts_0,	/* 1 */
		nts_1,	/* 2 */
		nts_0,	/* 3 */
		nts_0,	/* 4 */
		nts_0,	/* 5 */
		nts_0,	/* 6 */
		nts_0,	/* 7 */
		nts_0,	/* 8 */
		nts_0,	/* 9 */
		nts_0,	/* 10 */
		nts_0,	/* 11 */
		nts_0,	/* 12 */
		nts_2,	/* 13 */
		nts_0,	/* 14 */
		nts_0,	/* 15 */
		nts_0,	/* 16 */
		nts_0,	/* 17 */
		nts_3,	/* 18 */
		nts_4,	/* 19 */
		nts_4,	/* 20 */
		nts_4,	/* 21 */
		nts_0,	/* 22 */
		nts_0,	/* 23 */
		nts_0,	/* 24 */
		nts_0,	/* 25 */
		nts_0,	/* 26 */
		nts_0,	/* 27 */
		nts_0,	/* 28 */
		nts_5,	/* 29 */
		nts_6,	/* 30 */
		nts_6,	/* 31 */
		nts_6,	/* 32 */
		nts_6,	/* 33 */
		nts_6,	/* 34 */
		nts_6,	/* 35 */
		nts_0,	/* 36 */
		nts_7,	/* 37 */
		nts_8,	/* 38 */
		nts_9,	/* 39 */
		nts_9,	/* 40 */
		nts_9,	/* 41 */
		nts_9,	/* 42 */
		nts_9,	/* 43 */
		nts_9,	/* 44 */
		nts_7,	/* 45 */
		nts_10,	/* 46 */
		nts_1,	/* 47 */
		nts_11,	/* 48 */
		nts_7,	/* 49 */
		nts_11,	/* 50 */
		nts_12,	/* 51 */
		nts_12,	/* 52 */
		nts_12,	/* 53 */
		nts_13,	/* 54 */
		nts_14,	/* 55 */
		nts_15,	/* 56 */
		nts_16,	/* 57 */
		nts_17,	/* 58 */
		nts_18,	/* 59 */
		nts_19,	/* 60 */
		nts_0,	/* 61 */
		nts_0,	/* 62 */
		nts_7,	/* 63 */
		nts_20,	/* 64 */
		nts_21,	/* 65 */
		nts_20,	/* 66 */
		nts_21,	/* 67 */
		nts_22,	/* 68 */
		nts_21,	/* 69 */
		nts_23,	/* 70 */
		nts_20,	/* 71 */
		nts_21,	/* 72 */
		nts_20,	/* 73 */
		nts_21,	/* 74 */
		nts_20,	/* 75 */
		nts_21,	/* 76 */
		nts_24,	/* 77 */
		nts_24,	/* 78 */
		nts_1,	/* 79 */
		nts_1,	/* 80 */
		nts_20,	/* 81 */
		nts_21,	/* 82 */
		nts_20,	/* 83 */
		nts_21,	/* 84 */
		nts_22,	/* 85 */
		nts_21,	/* 86 */
		nts_23,	/* 87 */
		nts_20,	/* 88 */
		nts_21,	/* 89 */
		nts_20,	/* 90 */
		nts_21,	/* 91 */
		nts_20,	/* 92 */
		nts_21,	/* 93 */
		nts_24,	/* 94 */
		nts_24,	/* 95 */
		nts_1,	/* 96 */
		nts_1,	/* 97 */
		nts_20,	/* 98 */
		nts_21,	/* 99 */
		nts_20,	/* 100 */
		nts_21,	/* 101 */
		nts_22,	/* 102 */
		nts_21,	/* 103 */
		nts_23,	/* 104 */
		nts_20,	/* 105 */
		nts_21,	/* 106 */
		nts_20,	/* 107 */
		nts_21,	/* 108 */
		nts_20,	/* 109 */
		nts_21,	/* 110 */
		nts_24,	/* 111 */
		nts_24,	/* 112 */
		nts_1,	/* 113 */
		nts_1,	/* 114 */
		nts_25,	/* 115 */
		nts_25,	/* 116 */
		nts_25,	/* 117 */
		nts_26,	/* 118 */
		nts_26,	/* 119 */
		nts_26,	/* 120 */
		nts_0,	/* 121 */
		nts_0,	/* 122 */
		nts_0,	/* 123 */
		nts_0,	/* 124 */
		nts_0,	/* 125 */
		nts_0,	/* 126 */
		nts_0,	/* 127 */
		nts_0,	/* 128 */
		nts_0,	/* 129 */
		nts_0,	/* 130 */
		nts_7,	/* 131 */
		nts_0,	/* 132 */
		nts_21,	/* 133 */
		nts_1,	/* 134 */
		nts_7,	/* 135 */
		nts_7,	/* 136 */
		nts_7,	/* 137 */
		nts_27,	/* 138 */
		nts_28,	/* 139 */
		nts_27,	/* 140 */
		nts_28,	/* 141 */
		nts_27,	/* 142 */
		nts_28,	/* 143 */
		nts_29,	/* 144 */
		nts_29,	/* 145 */
		nts_29,	/* 146 */
		nts_29,	/* 147 */
		nts_29,	/* 148 */
		nts_29,	/* 149 */
		nts_29,	/* 150 */
		nts_29,	/* 151 */
		nts_29,	/* 152 */
		nts_29,	/* 153 */
		nts_30,	/* 154 */
		nts_30,	/* 155 */
		nts_30,	/* 156 */
		nts_30,	/* 157 */
		nts_30,	/* 158 */
		nts_30,	/* 159 */
		nts_30,	/* 160 */
		nts_30,	/* 161 */
		nts_30,	/* 162 */
		nts_30,	/* 163 */
		nts_0,	/* 164 */
		nts_20,	/* 165 */
		nts_31,	/* 166 */
		nts_20,	/* 167 */
		nts_31,	/* 168 */
		nts_20,	/* 169 */
		nts_31,	/* 170 */
		nts_32,	/* 171 */
		nts_0,	/* 172 */
		nts_0,	/* 173 */
		nts_0,	/* 174 */
		nts_0,	/* 175 */
		nts_0,	/* 176 */
		nts_1,	/* 177 */
		nts_11,	/* 178 */
		nts_1,	/* 179 */
		nts_33,	/* 180 */
		nts_22,	/* 181 */
		nts_21,	/* 182 */
		nts_22,	/* 183 */
		nts_21,	/* 184 */
		nts_22,	/* 185 */
		nts_21,	/* 186 */
		nts_7,	/* 187 */
		nts_7,	/* 188 */
		nts_7,	/* 189 */
		nts_0,	/* 190 */
		nts_0,	/* 191 */
		nts_0,	/* 192 */
	};

	decode_inst = {
		0,
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		29,
		38,
		54,
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
		122,
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
		185,
		186,
		187,
		188,
		189,
		190,
		191,
		192,
	};

	decode_tm = {
		0,
		45,
		46,
	};

	decode_const = {
		0,
		9,
		10,
		11,
		12,
		13,
	};

	decode_immed = {
		0,
		14,
		15,
		16,
		17,
		18,
	};

	decode_addr = {
		0,
		58,
		59,
		60,
	};

	decode_mem = {
		0,
		19,
		20,
		21,
	};

	decode_t = {
		0,
		22,
		23,
		24,
		25,
		26,
		27,
		51,
		52,
		53,
	};

	decode_arg = {
		0,
		28,
		30,
		31,
		32,
		33,
		34,
		35,
	};

	decode_param = {
		0,
		36,
		37,
		39,
		40,
		41,
		42,
		43,
		44,
	};

	decode_tmi = {
		0,
		47,
		48,
	};

	decode_ti = {
		0,
		49,
		50,
	};

	decode_base = {
		0,
		55,
		56,
	};

	decode_index = {
		0,
		57,
	};

	decode_flags = {
		0,
		137,
	};

	nts_name = new System.String {
		null,	/* 0 */
		"inst",	/* inst*/
		"tm",	/* tm*/
		"const",	/* const*/
		"immed",	/* immed*/
		"addr",	/* addr*/
		"mem",	/* mem*/
		"t",	/* t*/
		"arg",	/* arg*/
		"param",	/* param*/
		"tmi",	/* tmi*/
		"ti",	/* ti*/
		"base",	/* base*/
		"index",	/* index*/
		"flags",	/* flags*/
	};
	result = new MTreeFactory {
		null,

	new MTreeFactory1(),

	new MTreeFactory2(),

	new MTreeFactory3(),

	new MTreeFactory4(),

	new MTreeFactory5(),

	new MTreeFactory6(),

	new MTreeFactory7(),

	new MTreeFactory8(),

	new MTreeFactory9(),

	new MTreeFactory10(),

	new MTreeFactory11(),

	new MTreeFactory12(),

	new MTreeFactory13(),

	new MTreeFactory14(),

	new MTreeFactory15(),

	new MTreeFactory16(),

	new MTreeFactory17(),

	new MTreeFactory18(),

	new MTreeFactory19(),

	new MTreeFactory20(),

	new MTreeFactory21(),

	new MTreeFactory22(),

	new MTreeFactory23(),

	new MTreeFactory24(),

	new MTreeFactory25(),

	new MTreeFactory26(),

	new MTreeFactory27(),

	new MTreeFactory28(),

	new MTreeFactory29(),

	new MTreeFactory30(),

	new MTreeFactory31(),

	new MTreeFactory32(),

	new MTreeFactory33(),

	new MTreeFactory34(),

	new MTreeFactory35(),

	new MTreeFactory36(),

	new MTreeFactory37(),

	new MTreeFactory38(),

	new MTreeFactory39(),

	new MTreeFactory40(),

	new MTreeFactory41(),

	new MTreeFactory42(),

	new MTreeFactory43(),

	new MTreeFactory44(),

	new MTreeFactory45(),

	new MTreeFactory46(),

	new MTreeFactory47(),

	new MTreeFactory48(),

	new MTreeFactory49(),

	new MTreeFactory50(),

	new MTreeFactory51(),

	new MTreeFactory52(),

	new MTreeFactory53(),

	new MTreeFactory54(),

	new MTreeFactory55(),

	new MTreeFactory56(),

	new MTreeFactory57(),

	new MTreeFactory58(),

	new MTreeFactory59(),

	new MTreeFactory60(),

	new MTreeFactory61(),

	new MTreeFactory62(),

	new MTreeFactory63(),

	new MTreeFactory64(),

	new MTreeFactory65(),

	new MTreeFactory66(),

	new MTreeFactory67(),

	new MTreeFactory68(),

	new MTreeFactory69(),

	new MTreeFactory70(),

	new MTreeFactory71(),

	new MTreeFactory72(),

	new MTreeFactory73(),

	new MTreeFactory74(),

	new MTreeFactory75(),

	new MTreeFactory76(),

	new MTreeFactory77(),

	new MTreeFactory78(),

	new MTreeFactory79(),

	new MTreeFactory80(),

	new MTreeFactory81(),

	new MTreeFactory82(),

	new MTreeFactory83(),

	new MTreeFactory84(),

	new MTreeFactory85(),

	new MTreeFactory86(),

	new MTreeFactory87(),

	new MTreeFactory88(),

	new MTreeFactory89(),

	new MTreeFactory90(),

	new MTreeFactory91(),

	new MTreeFactory92(),

	new MTreeFactory93(),

	new MTreeFactory94(),

	new MTreeFactory95(),

	new MTreeFactory96(),

	new MTreeFactory97(),

	new MTreeFactory98(),

	new MTreeFactory99(),

	new MTreeFactory100(),

	new MTreeFactory101(),

	new MTreeFactory102(),

	new MTreeFactory103(),

	new MTreeFactory104(),

	new MTreeFactory105(),

	new MTreeFactory106(),

	new MTreeFactory107(),

	new MTreeFactory108(),

	new MTreeFactory109(),

	new MTreeFactory110(),

	new MTreeFactory111(),

	new MTreeFactory112(),

	new MTreeFactory113(),

	new MTreeFactory114(),

	new MTreeFactory115(),

	new MTreeFactory116(),

	new MTreeFactory117(),

	new MTreeFactory118(),

	new MTreeFactory119(),

	new MTreeFactory120(),

	new MTreeFactory121(),

	new MTreeFactory122(),

	new MTreeFactory123(),

	new MTreeFactory124(),

	new MTreeFactory125(),

	new MTreeFactory126(),

	new MTreeFactory127(),

	new MTreeFactory128(),

	new MTreeFactory129(),

	new MTreeFactory130(),

	new MTreeFactory131(),

	new MTreeFactory132(),

	new MTreeFactory133(),

	new MTreeFactory134(),

	new MTreeFactory135(),

	new MTreeFactory136(),

	new MTreeFactory137(),

	new MTreeFactory138(),

	new MTreeFactory139(),

	new MTreeFactory140(),

	new MTreeFactory141(),

	new MTreeFactory142(),

	new MTreeFactory143(),

	new MTreeFactory144(),

	new MTreeFactory145(),

	new MTreeFactory146(),

	new MTreeFactory147(),

	new MTreeFactory148(),

	new MTreeFactory149(),

	new MTreeFactory150(),

	new MTreeFactory151(),

	new MTreeFactory152(),

	new MTreeFactory153(),

	new MTreeFactory154(),

	new MTreeFactory155(),

	new MTreeFactory156(),

	new MTreeFactory157(),

	new MTreeFactory158(),

	new MTreeFactory159(),

	new MTreeFactory160(),

	new MTreeFactory161(),

	new MTreeFactory162(),

	new MTreeFactory163(),

	new MTreeFactory164(),

	new MTreeFactory165(),

	new MTreeFactory166(),

	new MTreeFactory167(),

	new MTreeFactory168(),

	new MTreeFactory169(),

	new MTreeFactory170(),

	new MTreeFactory171(),

	new MTreeFactory172(),

	new MTreeFactory173(),

	new MTreeFactory174(),

	new MTreeFactory175(),

	new MTreeFactory176(),

	new MTreeFactory177(),

	new MTreeFactory178(),

	new MTreeFactory179(),

	new MTreeFactory180(),

	new MTreeFactory181(),

	new MTreeFactory182(),

	new MTreeFactory183(),

	new MTreeFactory184(),

	new MTreeFactory185(),

	new MTreeFactory186(),

	new MTreeFactory187(),

	new MTreeFactory188(),

	new MTreeFactory189(),

	new MTreeFactory190(),

	new MTreeFactory191(),

	new MTreeFactory192(),
	};
}
void closure_tm(ITree a, int c) {
	State p = a.getGenState();
	// match tm -> tmi 47->tmi ?
	if(c + 0 < p.cost[tmi_NT]) {
		p.cost[tmi_NT] = c + 0;
		p.rule[tmi_NT] = 1;
		closure_tmi(a, c + 0);
	}
}

void closure_const(ITree a, int c) {
	State p = a.getGenState();
	// match const -> base 55->base ?
	if(c + 0 < p.cost[base_NT]) {
		p.cost[base_NT] = c + 0;
		p.rule[base_NT] = 1;
		closure_base(a, c + 0);
	}
}

void closure_immed(ITree a, int c) {
	State p = a.getGenState();
	// match immed -> ti 50->ti ?
	if(c + 0 < p.cost[ti_NT]) {
		p.cost[ti_NT] = c + 0;
		p.rule[ti_NT] = 2;
	}
	// match immed -> tmi 48->tmi ?
	if(c + 0 < p.cost[tmi_NT]) {
		p.cost[tmi_NT] = c + 0;
		p.rule[tmi_NT] = 2;
		closure_tmi(a, c + 0);
	}
}

void closure_mem(ITree a, int c) {
	State p = a.getGenState();
	// match mem -> tm 46->tm ?
	if(c + 0 < p.cost[tm_NT]) {
		p.cost[tm_NT] = c + 0;
		p.rule[tm_NT] = 2;
		closure_tm(a, c + 0);
	}
}

void closure_t(ITree a, int c) {
	State p = a.getGenState();
	// match t -> flags 137->flags ?
	if(c + 0 < p.cost[flags_NT]) {
		p.cost[flags_NT] = c + 0;
		p.rule[flags_NT] = 1;
	}
	// match t -> ti 49->ti ?
	if(c + 0 < p.cost[ti_NT]) {
		p.cost[ti_NT] = c + 0;
		p.rule[ti_NT] = 1;
	}
	// match t -> tm 45->tm ?
	if(c + 0 < p.cost[tm_NT]) {
		p.cost[tm_NT] = c + 0;
		p.rule[tm_NT] = 1;
		closure_tm(a, c + 0);
	}
}

void closure_arg(ITree a, int c) {
	State p = a.getGenState();
	// match arg -> inst 29->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 9;
	}
}

void closure_param(ITree a, int c) {
	State p = a.getGenState();
	// match param -> inst 38->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 10;
	}
}

void closure_tmi(ITree a, int c) {
	State p = a.getGenState();
	// match tmi -> inst 54->inst ?
	if(c + 0 < p.cost[inst_NT]) {
		p.cost[inst_NT] = c + 0;
		p.rule[inst_NT] = 11;
	}
}

void closure_base(ITree a, int c) {
	State p = a.getGenState();
	// match base -> addr 59->addr ?
	if(c + 0 < p.cost[addr_NT]) {
		p.cost[addr_NT] = c + 0;
		p.rule[addr_NT] = 2;
	}
}

void closure_index(ITree a, int c) {
	State p = a.getGenState();
	// match index -> addr 60->addr ?
	if(c + 0 < p.cost[addr_NT]) {
		p.cost[addr_NT] = c + 0;
		p.rule[addr_NT] = 3;
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
		/* [INDIRECT_1 addr] -> mem 21 */		c = a.getLeft().getGenState().cost[addr_NT] + 
10;
		// match [INDIRECT_1 addr] -> mem 21->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 3;
			closure_mem(a, c + 0);
		}
		break;
		case 10: /* INDIRECT_4 */
		label(a.getLeft());
		/* [INDIRECT_4 addr] -> mem 20 */		c = a.getLeft().getGenState().cost[addr_NT] + 
10;
		// match [INDIRECT_4 addr] -> mem 20->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 2;
			closure_mem(a, c + 0);
		}
		break;
		case 11: /* INDIRECT_8 */
		label(a.getLeft());
		/* [INDIRECT_8 addr] -> mem 19 */		c = a.getLeft().getGenState().cost[addr_NT] + 
10;
		// match [INDIRECT_8 addr] -> mem 19->mem ?
		if(c + 0 < p.cost[mem_NT]) {
			p.cost[mem_NT] = c + 0;
			p.rule[mem_NT] = 1;
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
		/* [LEA_8 t addr] -> inst 171 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[addr_NT] + 
10;
		// match [LEA_8 t addr] -> inst 171->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 121;
		}
		break;
		case 25: /* ADD_1 */
		break;
		case 26: /* ADD_4 */
		break;
		case 27: /* ADD_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD_8 const t] -> base 56 */
		c = a.getLeft().getGenState().cost[const_NT] + 
a.getRight().getGenState().cost[t_NT] + 
0;
		// match [ADD_8 const t] -> base 56->base ?
		if(c + 0 < p.cost[base_NT]) {
			p.cost[base_NT] = c + 0;
			p.rule[base_NT] = 2;
			closure_base(a, c + 0);
		}
		/* [ADD_8 base index] -> addr 58 */
		c = a.getLeft().getGenState().cost[base_NT] + 
a.getRight().getGenState().cost[index_NT] + 
0;
		// match [ADD_8 base index] -> addr 58->addr ?
		if(c + 0 < p.cost[addr_NT]) {
			p.cost[addr_NT] = c + 0;
			p.rule[addr_NT] = 1;
		}
		break;
		case 29: /* ADD2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD2_1 tm ti] -> inst 98 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [ADD2_1 tm ti] -> inst 98->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 49;
		}
		/* [ADD2_1 t tm] -> inst 99 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [ADD2_1 t tm] -> inst 99->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 50;
		}
		break;
		case 30: /* ADD2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD2_4 tm ti] -> inst 81 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [ADD2_4 tm ti] -> inst 81->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 32;
		}
		/* [ADD2_4 t tm] -> inst 82 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [ADD2_4 t tm] -> inst 82->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 33;
		}
		break;
		case 31: /* ADD2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [ADD2_8 tm ti] -> inst 64 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [ADD2_8 tm ti] -> inst 64->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 15;
		}
		/* [ADD2_8 t tm] -> inst 65 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [ADD2_8 t tm] -> inst 65->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 16;
		}
		break;
		case 33: /* SUB_1 */
		break;
		case 34: /* SUB_4 */
		break;
		case 35: /* SUB_8 */
		break;
		case 37: /* SUB2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SUB2_1 tm ti] -> inst 100 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [SUB2_1 tm ti] -> inst 100->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 51;
		}
		/* [SUB2_1 t tm] -> inst 101 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [SUB2_1 t tm] -> inst 101->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 52;
		}
		break;
		case 38: /* SUB2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SUB2_4 tm ti] -> inst 83 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [SUB2_4 tm ti] -> inst 83->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 34;
		}
		/* [SUB2_4 t tm] -> inst 84 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [SUB2_4 t tm] -> inst 84->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 35;
		}
		break;
		case 39: /* SUB2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SUB2_8 tm ti] -> inst 66 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [SUB2_8 tm ti] -> inst 66->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 17;
		}
		/* [SUB2_8 t tm] -> inst 67 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [SUB2_8 t tm] -> inst 67->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 18;
		}
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
		break;
		case 51: /* MUL_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [MUL_8 t const] -> index 57 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[const_NT] + 
1;
		// match [MUL_8 t const] -> index 57->index ?
		if(c + 0 < p.cost[index_NT]) {
			p.cost[index_NT] = c + 0;
			p.rule[index_NT] = 1;
			closure_index(a, c + 0);
		}
		break;
		case 53: /* MUL2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [MUL2_1 t immed] -> inst 102 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[immed_NT] + 
10;
		// match [MUL2_1 t immed] -> inst 102->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 53;
		}
		/* [MUL2_1 t tm] -> inst 103 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [MUL2_1 t tm] -> inst 103->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 54;
		}
		break;
		case 54: /* MUL2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [MUL2_4 t immed] -> inst 85 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[immed_NT] + 
10;
		// match [MUL2_4 t immed] -> inst 85->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 36;
		}
		/* [MUL2_4 t tm] -> inst 86 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [MUL2_4 t tm] -> inst 86->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 37;
		}
		break;
		case 55: /* MUL2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [MUL2_8 t immed] -> inst 68 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[immed_NT] + 
10;
		// match [MUL2_8 t immed] -> inst 68->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 19;
		}
		/* [MUL2_8 t tm] -> inst 69 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [MUL2_8 t tm] -> inst 69->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 20;
		}
		break;
		case 57: /* DIV_1 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [DIV_1 [PAIR_1 t tm] t] -> inst 117 arity 2 */
			a.getLeft().getOperator() == 609 /* BB PAIR_1*/
		) {
			c = a.getLeft().getLeft().getGenState().cost[t_NT] + 
a.getLeft().getRight().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
			// match [DIV_1 [PAIR_1 t tm] t] -> inst 117->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 68;
			}
}
		break;
		case 58: /* DIV_4 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [DIV_4 [PAIR_4 t tm] t] -> inst 116 arity 2 */
			a.getLeft().getOperator() == 610 /* BB PAIR_4*/
		) {
			c = a.getLeft().getLeft().getGenState().cost[t_NT] + 
a.getLeft().getRight().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
			// match [DIV_4 [PAIR_4 t tm] t] -> inst 116->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 67;
			}
}
		break;
		case 59: /* DIV_8 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [DIV_8 [PAIR_8 t tm] t] -> inst 115 arity 2 */
			a.getLeft().getOperator() == 611 /* BB PAIR_8*/
		) {
			c = a.getLeft().getLeft().getGenState().cost[t_NT] + 
a.getLeft().getRight().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
			// match [DIV_8 [PAIR_8 t tm] t] -> inst 115->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 66;
			}
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
		if(/* [MOD_1 [PAIR_1 t t] tm] -> inst 120 arity 2 */
			a.getLeft().getOperator() == 609 /* BB PAIR_1*/
		) {
			c = a.getLeft().getLeft().getGenState().cost[t_NT] + 
a.getLeft().getRight().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
			// match [MOD_1 [PAIR_1 t t] tm] -> inst 120->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 71;
			}
}
		break;
		case 74: /* MOD_4 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [MOD_4 [PAIR_4 t t] tm] -> inst 119 arity 2 */
			a.getLeft().getOperator() == 610 /* BB PAIR_4*/
		) {
			c = a.getLeft().getLeft().getGenState().cost[t_NT] + 
a.getLeft().getRight().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
			// match [MOD_4 [PAIR_4 t t] tm] -> inst 119->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 70;
			}
}
		break;
		case 75: /* MOD_8 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [MOD_8 [PAIR_8 t t] tm] -> inst 118 arity 2 */
			a.getLeft().getOperator() == 611 /* BB PAIR_8*/
		) {
			c = a.getLeft().getLeft().getGenState().cost[t_NT] + 
a.getLeft().getRight().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
			// match [MOD_8 [PAIR_8 t t] tm] -> inst 118->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 69;
			}
}
		break;
		case 77: /* MOD2_1 */
		break;
		case 78: /* MOD2_4 */
		break;
		case 79: /* MOD2_8 */
		break;
		case 81: /* SHL_1 */
		break;
		case 82: /* SHL_4 */
		break;
		case 83: /* SHL_8 */
		break;
		case 85: /* SHL2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHL2_1 tm t] -> inst 111 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
		// match [SHL2_1 tm t] -> inst 111->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 62;
		}
		break;
		case 86: /* SHL2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHL2_4 tm t] -> inst 94 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
		// match [SHL2_4 tm t] -> inst 94->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 45;
		}
		break;
		case 87: /* SHL2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHL2_8 tm t] -> inst 77 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
		// match [SHL2_8 tm t] -> inst 77->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 28;
		}
		break;
		case 89: /* SHAR_1 */
		break;
		case 90: /* SHAR_4 */
		break;
		case 91: /* SHAR_8 */
		break;
		case 93: /* SHAR2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHAR2_1 tm t] -> inst 112 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
		// match [SHAR2_1 tm t] -> inst 112->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 63;
		}
		break;
		case 94: /* SHAR2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHAR2_4 tm t] -> inst 95 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
		// match [SHAR2_4 tm t] -> inst 95->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 46;
		}
		break;
		case 95: /* SHAR2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SHAR2_8 tm t] -> inst 78 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[t_NT] + 
10;
		// match [SHAR2_8 tm t] -> inst 78->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 29;
		}
		break;
		case 97: /* EQ_1 */
		break;
		case 98: /* EQ_4 */
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
		break;
		case 106: /* NE_4 */
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
		break;
		case 114: /* GT_4 */
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
		break;
		case 122: /* LT_4 */
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
		break;
		case 130: /* GE_4 */
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
		break;
		case 138: /* LE_4 */
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
		break;
		case 146: /* GTU_4 */
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
		break;
		case 154: /* LTU_4 */
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
		break;
		case 162: /* GEU_4 */
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
		break;
		case 170: /* LEU_4 */
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
		break;
		case 178: /* AND_4 */
		break;
		case 179: /* AND_8 */
		break;
		case 181: /* AND2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [AND2_1 tm ti] -> inst 105 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [AND2_1 tm ti] -> inst 105->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 56;
		}
		/* [AND2_1 t tm] -> inst 106 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [AND2_1 t tm] -> inst 106->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 57;
		}
		break;
		case 182: /* AND2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [AND2_4 tm ti] -> inst 88 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [AND2_4 tm ti] -> inst 88->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 39;
		}
		/* [AND2_4 t tm] -> inst 89 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [AND2_4 t tm] -> inst 89->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 40;
		}
		break;
		case 183: /* AND2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [AND2_8 tm ti] -> inst 71 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [AND2_8 tm ti] -> inst 71->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 22;
		}
		/* [AND2_8 t tm] -> inst 72 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [AND2_8 t tm] -> inst 72->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 23;
		}
		break;
		case 185: /* OR_1 */
		break;
		case 186: /* OR_4 */
		break;
		case 187: /* OR_8 */
		break;
		case 189: /* OR2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [OR2_1 tm ti] -> inst 107 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [OR2_1 tm ti] -> inst 107->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 58;
		}
		/* [OR2_1 t tm] -> inst 108 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [OR2_1 t tm] -> inst 108->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 59;
		}
		break;
		case 190: /* OR2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [OR2_4 tm ti] -> inst 90 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [OR2_4 tm ti] -> inst 90->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 41;
		}
		/* [OR2_4 t tm] -> inst 91 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [OR2_4 t tm] -> inst 91->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 42;
		}
		break;
		case 191: /* OR2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [OR2_8 tm ti] -> inst 73 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [OR2_8 tm ti] -> inst 73->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 24;
		}
		/* [OR2_8 t tm] -> inst 74 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [OR2_8 t tm] -> inst 74->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 25;
		}
		break;
		case 193: /* XOR_1 */
		break;
		case 194: /* XOR_4 */
		break;
		case 195: /* XOR_8 */
		break;
		case 197: /* XOR2_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [XOR2_1 tm ti] -> inst 109 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [XOR2_1 tm ti] -> inst 109->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 60;
		}
		/* [XOR2_1 t tm] -> inst 110 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [XOR2_1 t tm] -> inst 110->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 61;
		}
		break;
		case 198: /* XOR2_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [XOR2_4 tm ti] -> inst 92 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [XOR2_4 tm ti] -> inst 92->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 43;
		}
		/* [XOR2_4 t tm] -> inst 93 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [XOR2_4 t tm] -> inst 93->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 44;
		}
		break;
		case 199: /* XOR2_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [XOR2_8 tm ti] -> inst 75 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
10;
		// match [XOR2_8 tm ti] -> inst 75->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 26;
		}
		/* [XOR2_8 t tm] -> inst 76 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [XOR2_8 t tm] -> inst 76->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 27;
		}
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
		break;
		case 202: /* NOT_4 */
		break;
		case 203: /* NOT_8 */
		break;
		case 205: /* NOT2_1 */
		label(a.getLeft());
		/* [NOT2_1 tm] -> inst 114 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [NOT2_1 tm] -> inst 114->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 65;
		}
		break;
		case 206: /* NOT2_4 */
		label(a.getLeft());
		/* [NOT2_4 tm] -> inst 97 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [NOT2_4 tm] -> inst 97->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 48;
		}
		break;
		case 207: /* NOT2_8 */
		label(a.getLeft());
		/* [NOT2_8 tm] -> inst 80 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [NOT2_8 tm] -> inst 80->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 31;
		}
		break;
		case 209: /* NEG_1 */
		break;
		case 210: /* NEG_4 */
		break;
		case 211: /* NEG_8 */
		break;
		case 213: /* NEG2_1 */
		label(a.getLeft());
		/* [NEG2_1 tm] -> inst 113 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [NEG2_1 tm] -> inst 113->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 64;
		}
		break;
		case 214: /* NEG2_4 */
		label(a.getLeft());
		/* [NEG2_4 tm] -> inst 96 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [NEG2_4 tm] -> inst 96->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 47;
		}
		break;
		case 215: /* NEG2_8 */
		label(a.getLeft());
		/* [NEG2_8 tm] -> inst 79 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [NEG2_8 tm] -> inst 79->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 30;
		}
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
		//NOP_0 -> inst 190->NOP_0 ?
		/* NOP_0 -> inst 190 arity 0 */
		// match NOP_0 -> inst 190->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 140;
		}
		break;
		case 240: /* COMMENT_0 */
		//COMMENT_0 -> inst 1->COMMENT_0 ?
		/* COMMENT_0 -> inst 1 arity 0 */
		// match COMMENT_0 -> inst 1->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 1;
		}
		//COMMENT_0 -> arg 28->COMMENT_0 ?
		/* COMMENT_0 -> arg 28 arity 0 */
		// match COMMENT_0 -> arg 28->arg ?
		if(10 + 0 < p.cost[arg_NT]) {
			p.cost[arg_NT] = 10 + 0;
			p.rule[arg_NT] = 1;
			closure_arg(a, 10 + 0);
		}
		//COMMENT_0 -> param 36->COMMENT_0 ?
		/* COMMENT_0 -> param 36 arity 0 */
		// match COMMENT_0 -> param 36->param ?
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
		break;
		case 260: /* OBJ_EQ2_0 */
		break;
		case 264: /* OBJ_NE_0 */
		break;
		case 268: /* OBJ_NE2_0 */
		break;
		case 272: /* BOUNDS_L_0 */
		break;
		case 280: /* BOUNDS_0 */
		break;
		case 288: /* BOUNDS_R_0 */
		break;
		case 297: /* LOCAL_1 */
		break;
		case 298: /* LOCAL_4 */
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
		//EXTERN_0 -> inst 123->EXTERN_0 ?
		/* EXTERN_0 -> inst 123 arity 0 */
		// match EXTERN_0 -> inst 123->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 74;
		}
		break;
		case 329: /* GLOBAL_1 */
		break;
		case 330: /* GLOBAL_4 */
		break;
		case 331: /* GLOBAL_8 */
		//GLOBAL_8 -> const 9->GLOBAL_8 ?
		/* GLOBAL_8 -> const 9 arity 0 */
		// match GLOBAL_8 -> const 9->const ?
		if(0 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 0 + 0;
			p.rule[const_NT] = 1;
			closure_const(a, 0 + 0);
		}
		//GLOBAL_8 -> immed 14->GLOBAL_8 ?
		/* GLOBAL_8 -> immed 14 arity 0 */
		// match GLOBAL_8 -> immed 14->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 1;
			closure_immed(a, 0 + 0);
		}
		break;
		case 336: /* LABEL_0 */
		//LABEL_0 -> const 11->LABEL_0 ?
		/* LABEL_0 -> const 11 arity 0 */
		// match LABEL_0 -> const 11->const ?
		if(50 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 50 + 0;
			p.rule[const_NT] = 3;
			closure_const(a, 50 + 0);
		}
		//LABEL_0 -> inst 121->LABEL_0 ?
		/* LABEL_0 -> inst 121 arity 0 */
		// match LABEL_0 -> inst 121->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 72;
		}
		break;
		case 344: /* DLABEL_0 */
		//DLABEL_0 -> const 12->DLABEL_0 ?
		/* DLABEL_0 -> const 12 arity 0 */
		// match DLABEL_0 -> const 12->const ?
		if(50 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 50 + 0;
			p.rule[const_NT] = 4;
			closure_const(a, 50 + 0);
		}
		//DLABEL_0 -> inst 122->DLABEL_0 ?
		/* DLABEL_0 -> inst 122 arity 0 */
		// match DLABEL_0 -> inst 122->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 73;
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
		label(a.getRight());
		/* [CAST_FROM1_4 t immed] -> inst 181 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[immed_NT] + 
10;
		// match [CAST_FROM1_4 t immed] -> inst 181->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 131;
		}
		/* [CAST_FROM1_4 t tm] -> inst 182 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [CAST_FROM1_4 t tm] -> inst 182->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 132;
		}
		break;
		case 355: /* CAST_FROM1_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [CAST_FROM1_8 t immed] -> inst 183 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[immed_NT] + 
10;
		// match [CAST_FROM1_8 t immed] -> inst 183->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 133;
		}
		/* [CAST_FROM1_8 t tm] -> inst 184 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [CAST_FROM1_8 t tm] -> inst 184->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 134;
		}
		break;
		case 358: /* CAST_FROM11_4 */
		break;
		case 359: /* CAST_FROM11_8 */
		break;
		case 361: /* CAST_FROM4_1 */
		break;
		case 362: /* CAST_FROM4_4 */
		break;
		case 363: /* CAST_FROM4_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [CAST_FROM4_8 t immed] -> inst 185 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[immed_NT] + 
10;
		// match [CAST_FROM4_8 t immed] -> inst 185->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 135;
		}
		/* [CAST_FROM4_8 t tm] -> inst 186 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [CAST_FROM4_8 t tm] -> inst 186->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 136;
		}
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
		/* [TREAT_AS_1 t] -> inst 189 */		c = a.getLeft().getGenState().cost[t_NT] + 
0;
		// match [TREAT_AS_1 t] -> inst 189->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 139;
		}
		break;
		case 378: /* TREAT_AS_4 */
		label(a.getLeft());
		/* [TREAT_AS_4 t] -> inst 188 */		c = a.getLeft().getGenState().cost[t_NT] + 
0;
		// match [TREAT_AS_4 t] -> inst 188->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 138;
		}
		break;
		case 379: /* TREAT_AS_8 */
		label(a.getLeft());
		/* [TREAT_AS_8 t] -> inst 187 */		c = a.getLeft().getGenState().cost[t_NT] + 
0;
		// match [TREAT_AS_8 t] -> inst 187->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 137;
		}
		break;
		case 381: /* TREAT_AS1_1 */
		break;
		case 382: /* TREAT_AS1_4 */
		break;
		case 383: /* TREAT_AS1_8 */
		break;
		case 384: /* CAST_CHECK_0 */
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
		//CONST_1 -> immed 17->CONST_1 ?
		/* CONST_1 -> immed 17 arity 0 */
		// match CONST_1 -> immed 17->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 4;
			closure_immed(a, 0 + 0);
		}
		break;
		case 410: /* CONST_4 */
		//CONST_4 -> immed 16->CONST_4 ?
		/* CONST_4 -> immed 16 arity 0 */
		// match CONST_4 -> immed 16->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 3;
			closure_immed(a, 0 + 0);
		}
		break;
		case 411: /* CONST_8 */
		//CONST_8 -> const 10->CONST_8 ?
		/* CONST_8 -> const 10 arity 0 */
		// match CONST_8 -> const 10->const ?
		if(0 + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = 0 + 0;
			p.rule[const_NT] = 2;
			closure_const(a, 0 + 0);
		}
		//CONST_8 -> immed 15->CONST_8 ?
		/* CONST_8 -> immed 15 arity 0 */
		// match CONST_8 -> immed 15->immed ?
		if(0 + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = 0 + 0;
			p.rule[immed_NT] = 2;
			closure_immed(a, 0 + 0);
		}
		break;
		case 416: /* CONST_STR_0 */
		//CONST_STR_0 -> inst 172->CONST_STR_0 ?
		/* CONST_STR_0 -> inst 172 arity 0 */
		// match CONST_STR_0 -> inst 172->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 122;
		}
		break;
		case 424: /* CONST_CSTR_0 */
		//CONST_CSTR_0 -> inst 173->CONST_CSTR_0 ?
		/* CONST_CSTR_0 -> inst 173 arity 0 */
		// match CONST_CSTR_0 -> inst 173->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 123;
		}
		break;
		case 432: /* BOX_0 */
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
		//CALL_0 -> inst 130->CALL_0 ?
		/* CALL_0 -> inst 130 arity 0 */
		// match CALL_0 -> inst 130->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 81;
		}
		break;
		case 496: /* STATIC_CALL_0 */
		label(a.getLeft());
		/* [STATIC_CALL_0 t] -> inst 131 */		c = a.getLeft().getGenState().cost[t_NT] + 
10;
		// match [STATIC_CALL_0 t] -> inst 131->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 82;
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
		label(a.getRight());
		/* [DYNAMIC_CALL_0 t tm] -> inst 133 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tm_NT] + 
10;
		// match [DYNAMIC_CALL_0 t tm] -> inst 133->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 84;
		}
		break;
		case 512: /* STATIC_DYNAMIC_CALL_0 */
		break;
		case 520: /* STATIC_CALL_DISCARD_0 */
		//STATIC_CALL_DISCARD_0 -> inst 132->STATIC_CALL_DISCARD_0 ?
		/* STATIC_CALL_DISCARD_0 -> inst 132 arity 0 */
		// match STATIC_CALL_DISCARD_0 -> inst 132->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 83;
		}
		break;
		case 528: /* DYNAMIC_CALL_DISCARD_0 */
		label(a.getLeft());
		/* [DYNAMIC_CALL_DISCARD_0 tm] -> inst 134 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [DYNAMIC_CALL_DISCARD_0 tm] -> inst 134->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 85;
		}
		break;
		case 536: /* STATIC_DYNAMIC_CALL_DISCARD_0 */
		break;
		case 544: /* PROC_CALL_0 */
		label(a.getLeft());
		/* [PROC_CALL_0 t] -> inst 135 */		c = a.getLeft().getGenState().cost[t_NT] + 
10;
		// match [PROC_CALL_0 t] -> inst 135->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 86;
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
		/* [PROC_CALL_DISCARD_0 t] -> inst 136 */		c = a.getLeft().getGenState().cost[t_NT] + 
10;
		// match [PROC_CALL_DISCARD_0 t] -> inst 136->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 87;
		}
		break;
		case 560: /* PROC_REF_0 */
		break;
		case 568: /* NEW_0 */
		break;
		case 576: /* NEW_FINALIZE_0 */
		break;
		case 584: /* NEW_ARRAY_0 */
		break;
		case 592: /* NEW_OBJ_ARRAY_0 */
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
		label(a.getLeft());
		label(a.getRight());
		break;
		case 610: /* PAIR_4 */
		label(a.getLeft());
		label(a.getRight());
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
		/* [PUSH_8 tm] -> inst 177 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [PUSH_8 tm] -> inst 177->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 127;
		}
		/* [PUSH_8 immed] -> inst 178 */		c = a.getLeft().getGenState().cost[immed_NT] + 
10;
		// match [PUSH_8 immed] -> inst 178->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 128;
		}
		break;
		case 625: /* POP_1 */
		break;
		case 626: /* POP_4 */
		break;
		case 627: /* POP_8 */
		label(a.getLeft());
		/* [POP_8 tm] -> inst 179 */		c = a.getLeft().getGenState().cost[tm_NT] + 
10;
		// match [POP_8 tm] -> inst 179->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 129;
		}
		break;
		case 632: /* RET_0 */
		//RET_0 -> inst 126->RET_0 ?
		/* RET_0 -> inst 126 arity 0 */
		// match RET_0 -> inst 126->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 77;
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
		break;
		case 656: /* TRY_0 */
		break;
		case 664: /* START_CATCH_0 */
		break;
		case 672: /* CATCH_0 */
		break;
		case 680: /* SUSPEND_CATCH_0 */
		break;
		case 688: /* END_FINALLY_0 */
		break;
		case 696: /* END_CATCH_0 */
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
		break;
		case 712: /* COND_RETHROW_0 */
		break;
		case 720: /* COND_RETURN_0 */
		break;
		case 729: /* THROW_RETURN_1 */
		break;
		case 730: /* THROW_RETURN_4 */
		break;
		case 731: /* THROW_RETURN_8 */
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
		break;
		case 760: /* SAVE_ALL_0 */
		//SAVE_ALL_0 -> inst 124->SAVE_ALL_0 ?
		/* SAVE_ALL_0 -> inst 124 arity 0 */
		// match SAVE_ALL_0 -> inst 124->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 75;
		}
		break;
		case 768: /* RESTORE_ALL_0 */
		//RESTORE_ALL_0 -> inst 125->RESTORE_ALL_0 ?
		/* RESTORE_ALL_0 -> inst 125 arity 0 */
		// match RESTORE_ALL_0 -> inst 125->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 76;
		}
		break;
		case 776: /* JUMP_0 */
		//JUMP_0 -> inst 164->JUMP_0 ?
		/* JUMP_0 -> inst 164 arity 0 */
		// match JUMP_0 -> inst 164->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 114;
		}
		break;
		case 784: /* DUMMY_JUMP_0 */
		//DUMMY_JUMP_0 -> inst 129->DUMMY_JUMP_0 ?
		/* DUMMY_JUMP_0 -> inst 129 arity 0 */
		// match DUMMY_JUMP_0 -> inst 129->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 80;
		}
		break;
		case 793: /* CMP_1 */
		label(a.getLeft());
		label(a.getRight());
		break;
		case 794: /* CMP_4 */
		label(a.getLeft());
		label(a.getRight());
		break;
		case 795: /* CMP_8 */
		label(a.getLeft());
		label(a.getRight());
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
		/* [DECBNN_8 tm] -> inst 2 */		c = a.getLeft().getGenState().cost[tm_NT] + 
20;
		// match [DECBNN_8 tm] -> inst 2->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 2;
		}
		break;
		case 805: /* DECBNN1_1 */
		break;
		case 806: /* DECBNN1_4 */
		break;
		case 807: /* DECBNN1_8 */
		break;
		case 808: /* BRANCH_0 */
		break;
		case 812: /* BRANCH1_0 */
		break;
		case 817: /* BRANCHZ_1 */
		break;
		case 818: /* BRANCHZ_4 */
		break;
		case 819: /* BRANCHZ_8 */
		break;
		case 821: /* BRANCHZ1_1 */
		break;
		case 822: /* BRANCHZ1_4 */
		break;
		case 823: /* BRANCHZ1_8 */
		break;
		case 825: /* BRANCHNZ_1 */
		break;
		case 826: /* BRANCHNZ_4 */
		break;
		case 827: /* BRANCHNZ_8 */
		break;
		case 829: /* BRANCHNZ1_1 */
		break;
		case 830: /* BRANCHNZ1_4 */
		break;
		case 831: /* BRANCHNZ1_8 */
		break;
		case 832: /* JE_0 */
		label(a.getLeft());
		/* [JE_0 flags] -> inst 144 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JE_0 flags] -> inst 144->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 94;
		}
		break;
		case 840: /* JNE_0 */
		label(a.getLeft());
		/* [JNE_0 flags] -> inst 145 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JNE_0 flags] -> inst 145->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 95;
		}
		break;
		case 848: /* JG_0 */
		label(a.getLeft());
		/* [JG_0 flags] -> inst 146 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JG_0 flags] -> inst 146->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 96;
		}
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
		label(a.getLeft());
		/* [JL_0 flags] -> inst 148 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JL_0 flags] -> inst 148->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 98;
		}
		break;
		case 864: /* JGE_0 */
		label(a.getLeft());
		/* [JGE_0 flags] -> inst 147 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JGE_0 flags] -> inst 147->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 97;
		}
		break;
		case 872: /* JLE_0 */
		label(a.getLeft());
		/* [JLE_0 flags] -> inst 149 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JLE_0 flags] -> inst 149->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 99;
		}
		break;
		case 880: /* JGU_0 */
		label(a.getLeft());
		/* [JGU_0 flags] -> inst 150 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JGU_0 flags] -> inst 150->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 100;
		}
		break;
		case 888: /* JLU_0 */
		label(a.getLeft());
		/* [JLU_0 flags] -> inst 152 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JLU_0 flags] -> inst 152->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 102;
		}
		break;
		case 896: /* JGEU_0 */
		label(a.getLeft());
		/* [JGEU_0 flags] -> inst 151 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JGEU_0 flags] -> inst 151->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 101;
		}
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
		label(a.getLeft());
		/* [JLEU_0 flags] -> inst 153 */		c = a.getLeft().getGenState().cost[flags_NT] + 
10;
		// match [JLEU_0 flags] -> inst 153->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 103;
		}
		break;
		case 913: /* SETE_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETE_1 t flags] -> inst 154 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETE_1 t flags] -> inst 154->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 104;
		}
		break;
		case 921: /* SETNE_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETNE_1 t flags] -> inst 155 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETNE_1 t flags] -> inst 155->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 105;
		}
		break;
		case 929: /* SETG_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETG_1 t flags] -> inst 156 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETG_1 t flags] -> inst 156->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 106;
		}
		break;
		case 937: /* SETL_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETL_1 t flags] -> inst 158 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETL_1 t flags] -> inst 158->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 108;
		}
		break;
		case 945: /* SETGE_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETGE_1 t flags] -> inst 157 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETGE_1 t flags] -> inst 157->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 107;
		}
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
		label(a.getLeft());
		label(a.getRight());
		/* [SETLE_1 t flags] -> inst 159 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETLE_1 t flags] -> inst 159->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 109;
		}
		break;
		case 961: /* SETGU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETGU_1 t flags] -> inst 160 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETGU_1 t flags] -> inst 160->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 110;
		}
		break;
		case 969: /* SETLU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETLU_1 t flags] -> inst 162 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETLU_1 t flags] -> inst 162->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 112;
		}
		break;
		case 977: /* SETGEU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETGEU_1 t flags] -> inst 161 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETGEU_1 t flags] -> inst 161->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 111;
		}
		break;
		case 985: /* SETLEU_1 */
		label(a.getLeft());
		label(a.getRight());
		/* [SETLEU_1 t flags] -> inst 163 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[flags_NT] + 
10;
		// match [SETLEU_1 t flags] -> inst 163->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 113;
		}
		break;
		case 992: /* RESERVE_0 */
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
		break;
		case 1008: /* ENTER_0 */
		//ENTER_0 -> inst 61->ENTER_0 ?
		/* ENTER_0 -> inst 61 arity 0 */
		// match ENTER_0 -> inst 61->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 12;
		}
		break;
		case 1016: /* LEAVE_0 */
		//LEAVE_0 -> inst 62->LEAVE_0 ?
		/* LEAVE_0 -> inst 62 arity 0 */
		// match LEAVE_0 -> inst 62->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 13;
		}
		break;
		case 1025: /* RESULT_1 */
		break;
		case 1026: /* RESULT_4 */
		break;
		case 1027: /* RESULT_8 */
		label(a.getLeft());
		/* [RESULT_8 t] -> param 37 */		c = a.getLeft().getGenState().cost[t_NT] + 
40;
		// match [RESULT_8 t] -> param 37->param ?
		if(c + 0 < p.cost[param_NT]) {
			p.cost[param_NT] = c + 0;
			p.rule[param_NT] = 2;
			closure_param(a, c + 0);
		}
		/* [RESULT_8 t] -> inst 63 */		c = a.getLeft().getGenState().cost[t_NT] + 
10;
		// match [RESULT_8 t] -> inst 63->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 14;
		}
		break;
		case 1032: /* RESULT_F_0 */
		break;
		case 1040: /* ENTER_LOOP_0 */
		//ENTER_LOOP_0 -> inst 127->ENTER_LOOP_0 ?
		/* ENTER_LOOP_0 -> inst 127 arity 0 */
		// match ENTER_LOOP_0 -> inst 127->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 78;
		}
		break;
		case 1048: /* LEAVE_LOOP_0 */
		//LEAVE_LOOP_0 -> inst 128->LEAVE_LOOP_0 ?
		/* LEAVE_LOOP_0 -> inst 128 arity 0 */
		// match LEAVE_LOOP_0 -> inst 128->inst ?
		if(10 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 10 + 0;
			p.rule[inst_NT] = 79;
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
		//LINE_0 -> inst 192->LINE_0 ?
		/* LINE_0 -> inst 192 arity 0 */
		// match LINE_0 -> inst 192->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 142;
		}
		break;
		case 1065: /* REG_VAR_1 */
		break;
		case 1066: /* REG_VAR_4 */
		break;
		case 1067: /* REG_VAR_8 */
		break;
		case 1073: /* REGISTER_1 */
		//REGISTER_1 -> t 27->REGISTER_1 ?
		/* REGISTER_1 -> t 27 arity 0 */
		// match REGISTER_1 -> t 27->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 6;
			closure_t(a, 0 + 0);
		}
		break;
		case 1074: /* REGISTER_4 */
		//REGISTER_4 -> t 26->REGISTER_4 ?
		/* REGISTER_4 -> t 26 arity 0 */
		// match REGISTER_4 -> t 26->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 5;
			closure_t(a, 0 + 0);
		}
		break;
		case 1075: /* REGISTER_8 */
		//REGISTER_8 -> t 25->REGISTER_8 ?
		/* REGISTER_8 -> t 25 arity 0 */
		// match REGISTER_8 -> t 25->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 4;
			closure_t(a, 0 + 0);
		}
		break;
		case 1081: /* TEMP_1 */
		//TEMP_1 -> t 24->TEMP_1 ?
		/* TEMP_1 -> t 24 arity 0 */
		// match TEMP_1 -> t 24->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 3;
			closure_t(a, 0 + 0);
		}
		break;
		case 1082: /* TEMP_4 */
		//TEMP_4 -> t 23->TEMP_4 ?
		/* TEMP_4 -> t 23 arity 0 */
		// match TEMP_4 -> t 23->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 2;
			closure_t(a, 0 + 0);
		}
		break;
		case 1083: /* TEMP_8 */
		//TEMP_8 -> t 22->TEMP_8 ?
		/* TEMP_8 -> t 22 arity 0 */
		// match TEMP_8 -> t 22->t ?
		if(0 + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = 0 + 0;
			p.rule[t_NT] = 1;
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
		/* [PARAM0_8 t param] -> param 39 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[param_NT] + 
0;
		// match [PARAM0_8 t param] -> param 39->param ?
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
		/* [PARAM1_8 t param] -> param 40 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[param_NT] + 
0;
		// match [PARAM1_8 t param] -> param 40->param ?
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
		/* [PARAM2_8 t param] -> param 41 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[param_NT] + 
0;
		// match [PARAM2_8 t param] -> param 41->param ?
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
		/* [PARAM3_8 t param] -> param 42 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[param_NT] + 
0;
		// match [PARAM3_8 t param] -> param 42->param ?
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
		/* [PARAM4_8 t param] -> param 43 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[param_NT] + 
0;
		// match [PARAM4_8 t param] -> param 43->param ?
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
		/* [PARAM5_8 t param] -> param 44 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[param_NT] + 
0;
		// match [PARAM5_8 t param] -> param 44->param ?
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
		/* [ARG0_8 t arg] -> arg 30 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[arg_NT] + 
0;
		// match [ARG0_8 t arg] -> arg 30->arg ?
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
		/* [ARG1_8 t arg] -> arg 31 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[arg_NT] + 
0;
		// match [ARG1_8 t arg] -> arg 31->arg ?
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
		/* [ARG2_8 t arg] -> arg 32 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[arg_NT] + 
0;
		// match [ARG2_8 t arg] -> arg 32->arg ?
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
		/* [ARG3_8 t arg] -> arg 33 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[arg_NT] + 
0;
		// match [ARG3_8 t arg] -> arg 33->arg ?
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
		/* [ARG4_8 t arg] -> arg 34 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[arg_NT] + 
0;
		// match [ARG4_8 t arg] -> arg 34->arg ?
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
		/* [ARG5_8 t arg] -> arg 35 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[arg_NT] + 
0;
		// match [ARG5_8 t arg] -> arg 35->arg ?
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
		/* [SEQ_1 inst t] -> t 53 */
		c = a.getLeft().getGenState().cost[inst_NT] + 
a.getRight().getGenState().cost[t_NT] + 
0;
		// match [SEQ_1 inst t] -> t 53->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 9;
			closure_t(a, c + 0);
		}
		break;
		case 1218: /* SEQ_4 */
		label(a.getLeft());
		label(a.getRight());
		/* [SEQ_4 inst t] -> t 52 */
		c = a.getLeft().getGenState().cost[inst_NT] + 
a.getRight().getGenState().cost[t_NT] + 
0;
		// match [SEQ_4 inst t] -> t 52->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 8;
			closure_t(a, c + 0);
		}
		break;
		case 1219: /* SEQ_8 */
		label(a.getLeft());
		label(a.getRight());
		/* [SEQ_8 inst const] -> const 13 */
		c = a.getLeft().getGenState().cost[inst_NT] + 
a.getRight().getGenState().cost[const_NT] + 
0;
		// match [SEQ_8 inst const] -> const 13->const ?
		if(c + 0 < p.cost[const_NT]) {
			p.cost[const_NT] = c + 0;
			p.rule[const_NT] = 5;
			closure_const(a, c + 0);
		}
		/* [SEQ_8 inst immed] -> immed 18 */
		c = a.getLeft().getGenState().cost[inst_NT] + 
a.getRight().getGenState().cost[immed_NT] + 
0;
		// match [SEQ_8 inst immed] -> immed 18->immed ?
		if(c + 0 < p.cost[immed_NT]) {
			p.cost[immed_NT] = c + 0;
			p.rule[immed_NT] = 5;
			closure_immed(a, c + 0);
		}
		/* [SEQ_8 inst t] -> t 51 */
		c = a.getLeft().getGenState().cost[inst_NT] + 
a.getRight().getGenState().cost[t_NT] + 
0;
		// match [SEQ_8 inst t] -> t 51->t ?
		if(c + 0 < p.cost[t_NT]) {
			p.cost[t_NT] = c + 0;
			p.rule[t_NT] = 7;
			closure_t(a, c + 0);
		}
		break;
		case 1224: /* LIST_0 */
		label(a.getLeft());
		label(a.getRight());
		/* [LIST_0 inst inst] -> inst 180 */
		c = a.getLeft().getGenState().cost[inst_NT] + 
a.getRight().getGenState().cost[inst_NT] + 
0;
		// match [LIST_0 inst inst] -> inst 180->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 130;
		}
		break;
		case 1233: /* COPY_1 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [COPY_1 t [MUL_1 tm immed]] -> inst 104 arity 2 */
			a.getRight().getOperator() == 49 /* BB MUL_1*/
		) {
			c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getLeft().getGenState().cost[tm_NT] + 
a.getRight().getRight().getGenState().cost[immed_NT] + 
10;
			// match [COPY_1 t [MUL_1 tm immed]] -> inst 104->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 55;
			}
}
		/* [COPY_1 tm ti] -> inst 169 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
5;
		// match [COPY_1 tm ti] -> inst 169->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 119;
		}
		/* [COPY_1 t tmi] -> inst 170 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tmi_NT] + 
5;
		// match [COPY_1 t tmi] -> inst 170->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 120;
		}
		break;
		case 1234: /* COPY_4 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [COPY_4 t [MUL_4 tm immed]] -> inst 87 arity 2 */
			a.getRight().getOperator() == 50 /* BB MUL_4*/
		) {
			c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getLeft().getGenState().cost[tm_NT] + 
a.getRight().getRight().getGenState().cost[immed_NT] + 
10;
			// match [COPY_4 t [MUL_4 tm immed]] -> inst 87->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 38;
			}
}
		/* [COPY_4 tm ti] -> inst 167 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
5;
		// match [COPY_4 tm ti] -> inst 167->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 117;
		}
		/* [COPY_4 t tmi] -> inst 168 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tmi_NT] + 
5;
		// match [COPY_4 t tmi] -> inst 168->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 118;
		}
		break;
		case 1235: /* COPY_8 */
		label(a.getLeft());
		label(a.getRight());
		if(/* [COPY_8 t [MUL_8 tm immed]] -> inst 70 arity 2 */
			a.getRight().getOperator() == 51 /* BB MUL_8*/
		) {
			c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getLeft().getGenState().cost[tm_NT] + 
a.getRight().getRight().getGenState().cost[immed_NT] + 
10;
			// match [COPY_8 t [MUL_8 tm immed]] -> inst 70->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 21;
			}
}
		if(/* [COPY_8 flags [CMP_8 tm ti]] -> inst 138 arity 2 */
			a.getRight().getOperator() == 795 /* BB CMP_8*/
		) {
			c = a.getLeft().getGenState().cost[flags_NT] + 
a.getRight().getLeft().getGenState().cost[tm_NT] + 
a.getRight().getRight().getGenState().cost[ti_NT] + 
10;
			// match [COPY_8 flags [CMP_8 tm ti]] -> inst 138->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 88;
			}
}
		if(/* [COPY_8 flags [CMP_8 t tmi]] -> inst 139 arity 2 */
			a.getRight().getOperator() == 795 /* BB CMP_8*/
		) {
			c = a.getLeft().getGenState().cost[flags_NT] + 
a.getRight().getLeft().getGenState().cost[t_NT] + 
a.getRight().getRight().getGenState().cost[tmi_NT] + 
10;
			// match [COPY_8 flags [CMP_8 t tmi]] -> inst 139->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 89;
			}
}
		if(/* [COPY_8 flags [CMP_4 tm ti]] -> inst 140 arity 2 */
			a.getRight().getOperator() == 794 /* BB CMP_4*/
		) {
			c = a.getLeft().getGenState().cost[flags_NT] + 
a.getRight().getLeft().getGenState().cost[tm_NT] + 
a.getRight().getRight().getGenState().cost[ti_NT] + 
10;
			// match [COPY_8 flags [CMP_4 tm ti]] -> inst 140->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 90;
			}
}
		if(/* [COPY_8 flags [CMP_4 t tmi]] -> inst 141 arity 2 */
			a.getRight().getOperator() == 794 /* BB CMP_4*/
		) {
			c = a.getLeft().getGenState().cost[flags_NT] + 
a.getRight().getLeft().getGenState().cost[t_NT] + 
a.getRight().getRight().getGenState().cost[tmi_NT] + 
10;
			// match [COPY_8 flags [CMP_4 t tmi]] -> inst 141->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 91;
			}
}
		if(/* [COPY_8 flags [CMP_1 tm ti]] -> inst 142 arity 2 */
			a.getRight().getOperator() == 793 /* BB CMP_1*/
		) {
			c = a.getLeft().getGenState().cost[flags_NT] + 
a.getRight().getLeft().getGenState().cost[tm_NT] + 
a.getRight().getRight().getGenState().cost[ti_NT] + 
10;
			// match [COPY_8 flags [CMP_1 tm ti]] -> inst 142->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 92;
			}
}
		if(/* [COPY_8 flags [CMP_1 t tmi]] -> inst 143 arity 2 */
			a.getRight().getOperator() == 793 /* BB CMP_1*/
		) {
			c = a.getLeft().getGenState().cost[flags_NT] + 
a.getRight().getLeft().getGenState().cost[t_NT] + 
a.getRight().getRight().getGenState().cost[tmi_NT] + 
10;
			// match [COPY_8 flags [CMP_1 t tmi]] -> inst 143->inst ?
			if(c + 0 < p.cost[inst_NT]) {
				p.cost[inst_NT] = c + 0;
				p.rule[inst_NT] = 93;
			}
}
		/* [COPY_8 tm ti] -> inst 165 */
		c = a.getLeft().getGenState().cost[tm_NT] + 
a.getRight().getGenState().cost[ti_NT] + 
5;
		// match [COPY_8 tm ti] -> inst 165->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 115;
		}
		/* [COPY_8 t tmi] -> inst 166 */
		c = a.getLeft().getGenState().cost[t_NT] + 
a.getRight().getGenState().cost[tmi_NT] + 
5;
		// match [COPY_8 t tmi] -> inst 166->inst ?
		if(c + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = c + 0;
			p.rule[inst_NT] = 116;
		}
		break;
		case 1240: /* STATIC_0 */
		//STATIC_0 -> inst 5->STATIC_0 ?
		/* STATIC_0 -> inst 5 arity 0 */
		// match STATIC_0 -> inst 5->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 5;
		}
		break;
		case 1248: /* TEXT_0 */
		//TEXT_0 -> inst 6->TEXT_0 ?
		/* TEXT_0 -> inst 6 arity 0 */
		// match TEXT_0 -> inst 6->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 6;
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
		//DATA_0 -> inst 7->DATA_0 ?
		/* DATA_0 -> inst 7 arity 0 */
		// match DATA_0 -> inst 7->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 7;
		}
		break;
		case 1264: /* RODATA_0 */
		//RODATA_0 -> inst 8->RODATA_0 ?
		/* RODATA_0 -> inst 8 arity 0 */
		// match RODATA_0 -> inst 8->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 8;
		}
		break;
		case 1272: /* UNWIND_0 */
		//UNWIND_0 -> inst 191->UNWIND_0 ?
		/* UNWIND_0 -> inst 191 arity 0 */
		// match UNWIND_0 -> inst 191->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 141;
		}
		break;
		case 1280: /* PUSHSEG_0 */
		//PUSHSEG_0 -> inst 3->PUSHSEG_0 ?
		/* PUSHSEG_0 -> inst 3 arity 0 */
		// match PUSHSEG_0 -> inst 3->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 3;
		}
		break;
		case 1288: /* POPSEG_0 */
		//POPSEG_0 -> inst 4->POPSEG_0 ?
		/* POPSEG_0 -> inst 4 arity 0 */
		// match POPSEG_0 -> inst 4->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 4;
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
		//DEFINT_1 -> inst 176->DEFINT_1 ?
		/* DEFINT_1 -> inst 176 arity 0 */
		// match DEFINT_1 -> inst 176->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 126;
		}
		break;
		case 1306: /* DEFINT_4 */
		//DEFINT_4 -> inst 175->DEFINT_4 ?
		/* DEFINT_4 -> inst 175 arity 0 */
		// match DEFINT_4 -> inst 175->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 125;
		}
		break;
		case 1307: /* DEFINT_8 */
		//DEFINT_8 -> inst 174->DEFINT_8 ?
		/* DEFINT_8 -> inst 174 arity 0 */
		// match DEFINT_8 -> inst 174->inst ?
		if(0 + 0 < p.cost[inst_NT]) {
			p.cost[inst_NT] = 0 + 0;
			p.rule[inst_NT] = 124;
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
	192/* LINE_0 -> inst 192 */,
	191/* UNWIND_0 -> inst 191 */,
	190/* NOP_0 -> inst 190 */,
	176/* DEFINT_1 -> inst 176 */,
	175/* DEFINT_4 -> inst 175 */,
	174/* DEFINT_8 -> inst 174 */,
	173/* CONST_CSTR_0 -> inst 173 */,
	172/* CONST_STR_0 -> inst 172 */,
	164/* JUMP_0 -> inst 164 */,
	132/* STATIC_CALL_DISCARD_0 -> inst 132 */,
	130/* CALL_0 -> inst 130 */,
	129/* DUMMY_JUMP_0 -> inst 129 */,
	128/* LEAVE_LOOP_0 -> inst 128 */,
	127/* ENTER_LOOP_0 -> inst 127 */,
	126/* RET_0 -> inst 126 */,
	125/* RESTORE_ALL_0 -> inst 125 */,
	124/* SAVE_ALL_0 -> inst 124 */,
	123/* EXTERN_0 -> inst 123 */,
	122/* DLABEL_0 -> inst 122 */,
	121/* LABEL_0 -> inst 121 */,
	62/* LEAVE_0 -> inst 62 */,
	61/* ENTER_0 -> inst 61 */,
	36/* COMMENT_0 -> param 36 */,
	28/* COMMENT_0 -> arg 28 */,
	27/* REGISTER_1 -> t 27 */,
	26/* REGISTER_4 -> t 26 */,
	25/* REGISTER_8 -> t 25 */,
	24/* TEMP_1 -> t 24 */,
	23/* TEMP_4 -> t 23 */,
	22/* TEMP_8 -> t 22 */,
	17/* CONST_1 -> immed 17 */,
	16/* CONST_4 -> immed 16 */,
	15/* CONST_8 -> immed 15 */,
	14/* GLOBAL_8 -> immed 14 */,
	12/* DLABEL_0 -> const 12 */,
	11/* LABEL_0 -> const 11 */,
	10/* CONST_8 -> const 10 */,
	9/* GLOBAL_8 -> const 9 */,
	8/* RODATA_0 -> inst 8 */,
	7/* DATA_0 -> inst 7 */,
	6/* TEXT_0 -> inst 6 */,
	5/* STATIC_0 -> inst 5 */,
	4/* POPSEG_0 -> inst 4 */,
	3/* PUSHSEG_0 -> inst 3 */,
	1/* COMMENT_0 -> inst 1 */:
		result = new ITree[0];

	case
	189/* [TREAT_AS_1 t] -> inst 189 */,
	188/* [TREAT_AS_4 t] -> inst 188 */,
	187/* [TREAT_AS_8 t] -> inst 187 */,
	179/* [POP_8 tm] -> inst 179 */,
	178/* [PUSH_8 immed] -> inst 178 */,
	177/* [PUSH_8 tm] -> inst 177 */,
	153/* [JLEU_0 flags] -> inst 153 */,
	152/* [JLU_0 flags] -> inst 152 */,
	151/* [JGEU_0 flags] -> inst 151 */,
	150/* [JGU_0 flags] -> inst 150 */,
	149/* [JLE_0 flags] -> inst 149 */,
	148/* [JL_0 flags] -> inst 148 */,
	147/* [JGE_0 flags] -> inst 147 */,
	146/* [JG_0 flags] -> inst 146 */,
	145/* [JNE_0 flags] -> inst 145 */,
	144/* [JE_0 flags] -> inst 144 */,
	136/* [PROC_CALL_DISCARD_0 t] -> inst 136 */,
	135/* [PROC_CALL_0 t] -> inst 135 */,
	134/* [DYNAMIC_CALL_DISCARD_0 tm] -> inst 134 */,
	131/* [STATIC_CALL_0 t] -> inst 131 */,
	114/* [NOT2_1 tm] -> inst 114 */,
	113/* [NEG2_1 tm] -> inst 113 */,
	97/* [NOT2_4 tm] -> inst 97 */,
	96/* [NEG2_4 tm] -> inst 96 */,
	80/* [NOT2_8 tm] -> inst 80 */,
	79/* [NEG2_8 tm] -> inst 79 */,
	63/* [RESULT_8 t] -> inst 63 */,
	37/* [RESULT_8 t] -> param 37 */,
	21/* [INDIRECT_1 addr] -> mem 21 */,
	20/* [INDIRECT_4 addr] -> mem 20 */,
	19/* [INDIRECT_8 addr] -> mem 19 */,
	2/* [DECBNN_8 tm] -> inst 2 */:
		result = new ITree[1];
		result[0] = p.getLeft();

	case
	186/* [CAST_FROM4_8 t tm] -> inst 186 */,
	185/* [CAST_FROM4_8 t immed] -> inst 185 */,
	184/* [CAST_FROM1_8 t tm] -> inst 184 */,
	183/* [CAST_FROM1_8 t immed] -> inst 183 */,
	182/* [CAST_FROM1_4 t tm] -> inst 182 */,
	181/* [CAST_FROM1_4 t immed] -> inst 181 */,
	180/* [LIST_0 inst inst] -> inst 180 */,
	171/* [LEA_8 t addr] -> inst 171 */,
	170/* [COPY_1 t tmi] -> inst 170 */,
	169/* [COPY_1 tm ti] -> inst 169 */,
	168/* [COPY_4 t tmi] -> inst 168 */,
	167/* [COPY_4 tm ti] -> inst 167 */,
	166/* [COPY_8 t tmi] -> inst 166 */,
	165/* [COPY_8 tm ti] -> inst 165 */,
	163/* [SETLEU_1 t flags] -> inst 163 */,
	162/* [SETLU_1 t flags] -> inst 162 */,
	161/* [SETGEU_1 t flags] -> inst 161 */,
	160/* [SETGU_1 t flags] -> inst 160 */,
	159/* [SETLE_1 t flags] -> inst 159 */,
	158/* [SETL_1 t flags] -> inst 158 */,
	157/* [SETGE_1 t flags] -> inst 157 */,
	156/* [SETG_1 t flags] -> inst 156 */,
	155/* [SETNE_1 t flags] -> inst 155 */,
	154/* [SETE_1 t flags] -> inst 154 */,
	133/* [DYNAMIC_CALL_0 t tm] -> inst 133 */,
	112/* [SHAR2_1 tm t] -> inst 112 */,
	111/* [SHL2_1 tm t] -> inst 111 */,
	110/* [XOR2_1 t tm] -> inst 110 */,
	109/* [XOR2_1 tm ti] -> inst 109 */,
	108/* [OR2_1 t tm] -> inst 108 */,
	107/* [OR2_1 tm ti] -> inst 107 */,
	106/* [AND2_1 t tm] -> inst 106 */,
	105/* [AND2_1 tm ti] -> inst 105 */,
	103/* [MUL2_1 t tm] -> inst 103 */,
	102/* [MUL2_1 t immed] -> inst 102 */,
	101/* [SUB2_1 t tm] -> inst 101 */,
	100/* [SUB2_1 tm ti] -> inst 100 */,
	99/* [ADD2_1 t tm] -> inst 99 */,
	98/* [ADD2_1 tm ti] -> inst 98 */,
	95/* [SHAR2_4 tm t] -> inst 95 */,
	94/* [SHL2_4 tm t] -> inst 94 */,
	93/* [XOR2_4 t tm] -> inst 93 */,
	92/* [XOR2_4 tm ti] -> inst 92 */,
	91/* [OR2_4 t tm] -> inst 91 */,
	90/* [OR2_4 tm ti] -> inst 90 */,
	89/* [AND2_4 t tm] -> inst 89 */,
	88/* [AND2_4 tm ti] -> inst 88 */,
	86/* [MUL2_4 t tm] -> inst 86 */,
	85/* [MUL2_4 t immed] -> inst 85 */,
	84/* [SUB2_4 t tm] -> inst 84 */,
	83/* [SUB2_4 tm ti] -> inst 83 */,
	82/* [ADD2_4 t tm] -> inst 82 */,
	81/* [ADD2_4 tm ti] -> inst 81 */,
	78/* [SHAR2_8 tm t] -> inst 78 */,
	77/* [SHL2_8 tm t] -> inst 77 */,
	76/* [XOR2_8 t tm] -> inst 76 */,
	75/* [XOR2_8 tm ti] -> inst 75 */,
	74/* [OR2_8 t tm] -> inst 74 */,
	73/* [OR2_8 tm ti] -> inst 73 */,
	72/* [AND2_8 t tm] -> inst 72 */,
	71/* [AND2_8 tm ti] -> inst 71 */,
	69/* [MUL2_8 t tm] -> inst 69 */,
	68/* [MUL2_8 t immed] -> inst 68 */,
	67/* [SUB2_8 t tm] -> inst 67 */,
	66/* [SUB2_8 tm ti] -> inst 66 */,
	65/* [ADD2_8 t tm] -> inst 65 */,
	64/* [ADD2_8 tm ti] -> inst 64 */,
	58/* [ADD_8 base index] -> addr 58 */,
	57/* [MUL_8 t const] -> index 57 */,
	56/* [ADD_8 const t] -> base 56 */,
	53/* [SEQ_1 inst t] -> t 53 */,
	52/* [SEQ_4 inst t] -> t 52 */,
	51/* [SEQ_8 inst t] -> t 51 */,
	44/* [PARAM5_8 t param] -> param 44 */,
	43/* [PARAM4_8 t param] -> param 43 */,
	42/* [PARAM3_8 t param] -> param 42 */,
	41/* [PARAM2_8 t param] -> param 41 */,
	40/* [PARAM1_8 t param] -> param 40 */,
	39/* [PARAM0_8 t param] -> param 39 */,
	35/* [ARG5_8 t arg] -> arg 35 */,
	34/* [ARG4_8 t arg] -> arg 34 */,
	33/* [ARG3_8 t arg] -> arg 33 */,
	32/* [ARG2_8 t arg] -> arg 32 */,
	31/* [ARG1_8 t arg] -> arg 31 */,
	30/* [ARG0_8 t arg] -> arg 30 */,
	18/* [SEQ_8 inst immed] -> immed 18 */,
	13/* [SEQ_8 inst const] -> const 13 */:
		result = new ITree[2];
		result[0] = p.getLeft();
		result[1] = p.getRight();

	case
	137/* t -> flags 137 */,
	60/* index -> addr 60 */,
	59/* base -> addr 59 */,
	55/* const -> base 55 */,
	54/* tmi -> inst 54 */,
	50/* immed -> ti 50 */,
	49/* t -> ti 49 */,
	48/* immed -> tmi 48 */,
	47/* tm -> tmi 47 */,
	46/* mem -> tm 46 */,
	45/* t -> tm 45 */,
	38/* param -> inst 38 */,
	29/* arg -> inst 29 */:
		result = new ITree[1];
		result[0] = p;

	case
	143/* [COPY_8 flags [CMP_1 t tmi]] -> inst 143 */,
	142/* [COPY_8 flags [CMP_1 tm ti]] -> inst 142 */,
	141/* [COPY_8 flags [CMP_4 t tmi]] -> inst 141 */,
	140/* [COPY_8 flags [CMP_4 tm ti]] -> inst 140 */,
	139/* [COPY_8 flags [CMP_8 t tmi]] -> inst 139 */,
	138/* [COPY_8 flags [CMP_8 tm ti]] -> inst 138 */,
	104/* [COPY_1 t [MUL_1 tm immed]] -> inst 104 */,
	87/* [COPY_4 t [MUL_4 tm immed]] -> inst 87 */,
	70/* [COPY_8 t [MUL_8 tm immed]] -> inst 70 */:
		result = new ITree[3];
		result[0] = p.getLeft();
		result[1] = p.getRight().getLeft();
		result[2] = p.getRight().getRight();

	case
	120/* [MOD_1 [PAIR_1 t t] tm] -> inst 120 */,
	119/* [MOD_4 [PAIR_4 t t] tm] -> inst 119 */,
	118/* [MOD_8 [PAIR_8 t t] tm] -> inst 118 */,
	117/* [DIV_1 [PAIR_1 t tm] t] -> inst 117 */,
	116/* [DIV_4 [PAIR_4 t tm] t] -> inst 116 */,
	115/* [DIV_8 [PAIR_8 t tm] t] -> inst 115 */:
		result = new ITree[3];
		result[0] = p.getLeft().getLeft();
		result[1] = p.getLeft().getRight();
		result[2] = p.getRight();

	default:
		throw new System.Exception("kids: bad rule number " + eruleno );
	}
	return result;
}
}
class MTreeFactory {
	MTree create(ITree node, MTree[] children) {
		return null;
	}
	void init() {}
}
class MTreeFactory1 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.COMMENT,new MConst(node.getString())));

	}
}
class MTreeFactory2 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MDecBranchNotNeg(Op.DECBNN_8,(children[0]),new MConst(node.getString())));

	}
}
class MTreeFactory3 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.PUSHSEG));

	}
}
class MTreeFactory4 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.POPSEG));

	}
}
class MTreeFactory5 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.STATIC));

	}
}
class MTreeFactory6 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.TEXT));

	}
}
class MTreeFactory7 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.DATA));

	}
}
class MTreeFactory8 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.RODATA));

	}
}
class MTreeFactory9 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MConst(node.getString());

	}
}
class MTreeFactory10 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MConst(node.getString());

	}
}
class MTreeFactory11 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MConst(node.getString());

	}
}
class MTreeFactory12 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MConst(node.getString());

	}
}
class MTreeFactory13 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MSeq((children[0]),(children[1]));

	}
}
class MTreeFactory14 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MImmediate(node.getString());

	}
}
class MTreeFactory15 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MImmediate(node.getString());

	}
}
class MTreeFactory16 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MImmediate(node.getString());

	}
}
class MTreeFactory17 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MImmediate(node.getString());

	}
}
class MTreeFactory18 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MSeq((children[0]),(children[1]));

	}
}
class MTreeFactory19 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MIndirect((children[0]));

	}
}
class MTreeFactory20 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MIndirect((children[0]));

	}
}
class MTreeFactory21 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MIndirect((children[0]));

	}
}
class MTreeFactory22 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MReg(node.getInt(),MSet.General);

	}
}
class MTreeFactory23 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MReg(node.getInt(),MSet.General);

	}
}
class MTreeFactory24 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MReg(node.getInt(),MSet.General);

	}
}
class MTreeFactory25 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MReg(node.getInt());

	}
}
class MTreeFactory26 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MReg(node.getInt());

	}
}
class MTreeFactory27 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MReg(node.getInt());

	}
}
class MTreeFactory28 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MConst(node.getString());

	}
}
class MTreeFactory29 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst((children[0]));

	}
}
class MTreeFactory30 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.ARG0,(children[0]).rset(MSet.Param0),(children[1]));

	}
}
class MTreeFactory31 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.ARG1,(children[0]).rset(MSet.Param1),(children[1]));

	}
}
class MTreeFactory32 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.ARG2,(children[0]).rset(MSet.Param2),(children[1]));

	}
}
class MTreeFactory33 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.ARG3,(children[0]).rset(MSet.Param3),(children[1]));

	}
}
class MTreeFactory34 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.ARG4,(children[0]).rset(MSet.Param4),(children[1]));

	}
}
class MTreeFactory35 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.ARG5,(children[0]).rset(MSet.Param5),(children[1]));

	}
}
class MTreeFactory36 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MConst(node.getString());

	}
}
class MTreeFactory37 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.PARAM0,(children[0]).rset(MSet.Return),new MConst("return"));

	}
}
class MTreeFactory38 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst((children[0]));

	}
}
class MTreeFactory39 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.PARAM0,(children[0]).rset(MSet.Param0),(children[1]));

	}
}
class MTreeFactory40 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.PARAM1,(children[0]).rset(MSet.Param1),(children[1]));

	}
}
class MTreeFactory41 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.PARAM2,(children[0]).rset(MSet.Param2),(children[1]));

	}
}
class MTreeFactory42 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.PARAM3,(children[0]).rset(MSet.Param3),(children[1]));

	}
}
class MTreeFactory43 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.PARAM4,(children[0]).rset(MSet.Param4),(children[1]));

	}
}
class MTreeFactory44 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MArg(Op.PARAM5,(children[0]).rset(MSet.Param5),(children[1]));

	}
}
class MTreeFactory45 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory46 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory47 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory48 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory49 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory50 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory51 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MSeq((children[0]),(children[1]));

	}
}
class MTreeFactory52 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MSeq((children[0]),(children[1]));

	}
}
class MTreeFactory53 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MSeq((children[0]),(children[1]));

	}
}
class MTreeFactory54 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory55 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return (children[0]);

	}
}
class MTreeFactory56 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MBase(Op.ADD,(children[0]),(children[1]));

	}
}
class MTreeFactory57 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MIndex(Op.MUL,(children[0]),(children[1]));

	}
}
class MTreeFactory58 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MAddress((children[0]),(children[1]));

	}
}
class MTreeFactory59 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MAddress((children[0]),null);

	}
}
class MTreeFactory60 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MAddress(null,(children[0]));

	}
}
class MTreeFactory61 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.ENTER));

	}
}
class MTreeFactory62 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.LEAVE));

	}
}
class MTreeFactory63 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MArg(Op.RESULT_8,(children[0]).rset(MSet.Return),new MConst("return value")));

	}
}
class MTreeFactory64 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.ADD2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory65 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.ADD2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory66 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SUB2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory67 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SUB2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory68 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.MUL2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory69 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.MUL2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory70 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA3(Op.MUL_8,(children[0]),(children[1]),(children[2])));

	}
}
class MTreeFactory71 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.AND2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory72 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.AND2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory73 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.OR2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory74 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.OR2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory75 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.XOR2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory76 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.XOR2_8,(children[0]),(children[1])));

	}
}
class MTreeFactory77 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SHL_8,(children[0]),(children[1]).rset(MSet.Param3)));

	}
}
class MTreeFactory78 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SHAR_8,(children[0]),(children[1]).rset(MSet.Param3)));

	}
}
class MTreeFactory79 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.NEG2_8,(children[0])));

	}
}
class MTreeFactory80 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.NOT2_8,(children[0])));

	}
}
class MTreeFactory81 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.ADD2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory82 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.ADD2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory83 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SUB2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory84 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SUB2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory85 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.MUL2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory86 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.MUL2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory87 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA3(Op.MUL_4,(children[0]),(children[1]),(children[2])));

	}
}
class MTreeFactory88 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.AND2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory89 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.AND2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory90 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.OR2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory91 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.OR2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory92 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.XOR2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory93 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.XOR2_4,(children[0]),(children[1])));

	}
}
class MTreeFactory94 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SHL_4,(children[0]),(children[1]).rset(MSet.Param3)));

	}
}
class MTreeFactory95 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SHAR_4,(children[0]),(children[1]).rset(MSet.Param3)));

	}
}
class MTreeFactory96 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.NEG_4,(children[0])));

	}
}
class MTreeFactory97 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.NOT_4,(children[0])));

	}
}
class MTreeFactory98 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.ADD2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory99 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.ADD2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory100 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SUB2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory101 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SUB2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory102 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.MUL2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory103 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.MUL2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory104 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA3(Op.MUL_1,(children[0]),(children[1]),(children[2])));

	}
}
class MTreeFactory105 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.AND2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory106 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.AND2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory107 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.OR2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory108 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.OR2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory109 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.XOR2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory110 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.XOR2_1,(children[0]),(children[1])));

	}
}
class MTreeFactory111 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SHL_1,(children[0]),(children[1]).rset(MSet.Param3)));

	}
}
class MTreeFactory112 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA2(Op.SHAR_1,(children[0]),(children[1]).rset(MSet.Param3)));

	}
}
class MTreeFactory113 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.NEG_1,(children[0])));

	}
}
class MTreeFactory114 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.NOT_1,(children[0])));

	}
}
class MTreeFactory115 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MDivide(Op.DIV_8,(children[0]).rset(MSet.Return),(children[1]).rset(MSet.Preserve),(children[2]).rset(MSet.Param2)));

	}
}
class MTreeFactory116 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MDivide(Op.DIV_4,(children[0]).rset(MSet.Return),(children[1]).rset(MSet.Preserve),(children[2]).rset(MSet.Param2)));

	}
}
class MTreeFactory117 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MDivide(Op.DIV_1,(children[0]).rset(MSet.Return),(children[1]).rset(MSet.Preserve),(children[2]).rset(MSet.Param2)));

	}
}
class MTreeFactory118 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MDivide(Op.MOD_8,(children[0]).rset(MSet.Param2),(children[1]).rset(MSet.Return),(children[2]).rset(MSet.Preserve)));

	}
}
class MTreeFactory119 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MDivide(Op.MOD_4,(children[0]).rset(MSet.Param2),(children[1]).rset(MSet.Return),(children[2]).rset(MSet.Preserve)));

	}
}
class MTreeFactory120 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MDivide(Op.MOD_1,(children[0]).rset(MSet.Param2),(children[1]).rset(MSet.Return),(children[2]).rset(MSet.Preserve)));

	}
}
class MTreeFactory121 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MLabel(Op.LABEL,node.getString()));

	}
}
class MTreeFactory122 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MLabel(Op.DLABEL,node.getString()));

	}
}
class MTreeFactory123 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.EXTERN,new MConst(node.getString())));

	}
}
class MTreeFactory124 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA0(Op.SAVE_ALL));

	}
}
class MTreeFactory125 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA0(Op.RESTORE_ALL));

	}
}
class MTreeFactory126 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA0(Op.RET));

	}
}
class MTreeFactory127 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA0(Op.ENTER_LOOP));

	}
}
class MTreeFactory128 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA0(Op.LEAVE_LOOP));

	}
}
class MTreeFactory129 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.DUMMY_JUMP,null,new MConst(node.getString())));

	}
}
class MTreeFactory130 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCall(Op.STATIC_CALL,null,new MConst(node.getString())));

	}
}
class MTreeFactory131 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCall(Op.STATIC_CALL,(children[0]).rset(MSet.Return),new MConst(node.getString())),MSet.CallR);

	}
}
class MTreeFactory132 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCall(Op.STATIC_CALL,null,new MConst(node.getString())),MSet.CallD);

	}
}
class MTreeFactory133 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCall(Op.DYNAMIC_CALL,(children[0]).rset(MSet.Return),(children[1])),MSet.CallR);

	}
}
class MTreeFactory134 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCall(Op.DYNAMIC_CALL,null,(children[0])),MSet.CallD);

	}
}
class MTreeFactory135 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCall(Op.PROC_CALL,(children[0]).rset(MSet.Return),null),MSet.CallR);

	}
}
class MTreeFactory136 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCall(Op.PROC_CALL,null,(children[0]).rset(MSet.Return)),MSet.CallR);

	}
}
class MTreeFactory137 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MReg((children[0]).getTemp(),MSet.Flags);

	}
}
class MTreeFactory138 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCompare(Op.CMP_8,(children[0]).rset(MSet.Flags),(children[1]),(children[2])));

	}
}
class MTreeFactory139 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCompare(Op.CMP_8,(children[0]).rset(MSet.Flags),(children[1]),(children[2])));

	}
}
class MTreeFactory140 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCompare(Op.CMP_4,(children[0]).rset(MSet.Flags),(children[1]),(children[2])));

	}
}
class MTreeFactory141 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCompare(Op.CMP_4,(children[0]).rset(MSet.Flags),(children[1]),(children[2])));

	}
}
class MTreeFactory142 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCompare(Op.CMP_1,(children[0]).rset(MSet.Flags),(children[1]),(children[2])));

	}
}
class MTreeFactory143 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCompare(Op.CMP_1,(children[0]).rset(MSet.Flags),(children[1]),(children[2])));

	}
}
class MTreeFactory144 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JE,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory145 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JNE,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory146 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JG,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory147 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JGE,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory148 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JL,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory149 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JLE,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory150 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JGU,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory151 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JGEU,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory152 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JLU,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory153 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JLEU,(children[0]).rset(MSet.Flags),new MConst(node.getString())));

	}
}
class MTreeFactory154 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETE_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory155 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETNE_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory156 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETG_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory157 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETGE_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory158 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETL_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory159 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETLE_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory160 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETGU_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory161 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETGEU_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory162 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETLU_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory163 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MCondSet(Op.SETLEU_1,(children[0]),(children[1]).rset(MSet.Flags)));

	}
}
class MTreeFactory164 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MJump(Op.JUMP,null,new MConst(node.getString())));

	}
}
class MTreeFactory165 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.COPY_8,(children[0]),(children[1])));

	}
}
class MTreeFactory166 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.COPY_8,(children[0]),(children[1])));

	}
}
class MTreeFactory167 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.COPY_4,(children[0]),(children[1])));

	}
}
class MTreeFactory168 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.COPY_4,(children[0]),(children[1])));

	}
}
class MTreeFactory169 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.COPY_1,(children[0]),(children[1])));

	}
}
class MTreeFactory170 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.COPY_1,(children[0]),(children[1])));

	}
}
class MTreeFactory171 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.LEA_8,(children[0]),(children[1])));

	}
}
class MTreeFactory172 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.CONST_STR,new MConst(node.getString())));

	}
}
class MTreeFactory173 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.CONST_CSTR,new MConst(node.getString())));

	}
}
class MTreeFactory174 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.DEFINT_8,new MConst(node.getString())));

	}
}
class MTreeFactory175 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.DEFINT_4,new MConst(node.getString())));

	}
}
class MTreeFactory176 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.DEFINT_1,new MConst(node.getString())));

	}
}
class MTreeFactory177 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MStack(Op.PUSH_8,(children[0])));

	}
}
class MTreeFactory178 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MStack(Op.PUSH_8,(children[0])));

	}
}
class MTreeFactory179 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MStack(Op.POP_8,(children[0])));

	}
}
class MTreeFactory180 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MList((children[0]),(children[1]));

	}
}
class MTreeFactory181 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.CAST_FROM1_4,(children[0]),(children[1])));

	}
}
class MTreeFactory182 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.CAST_FROM1_4,(children[0]),(children[1])));

	}
}
class MTreeFactory183 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.CAST_FROM1_8,(children[0]),(children[1])));

	}
}
class MTreeFactory184 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.CAST_FROM1_8,(children[0]),(children[1])));

	}
}
class MTreeFactory185 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.CAST_FROM4_8,(children[0]),(children[1])));

	}
}
class MTreeFactory186 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MMove(Op.CAST_FROM4_8,(children[0]),(children[1])));

	}
}
class MTreeFactory187 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.TREAT_AS_8,(children[0])));

	}
}
class MTreeFactory188 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.TREAT_AS_4,(children[0])));

	}
}
class MTreeFactory189 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA1(Op.TREAT_AS_1,(children[0])));

	}
}
class MTreeFactory190 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MA0(Op.NOP));

	}
}
class MTreeFactory191 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.UNWIND));

	}
}
class MTreeFactory192 extends MTreeFactory {
	void init() { super.init(); }
	MTree create(ITree node, MTree[] children) {
		return new MInst(new MData(Op.LINE,new MConst(node.getString())));

	}
}
}
