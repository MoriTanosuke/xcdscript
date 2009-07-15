//author: bobef
//use without restrictions at your own risk
//http://www.lessequal.com

module xchat_dscript;

private import xchatplugin;
private import std.string;
private import std.file;
private import std.stream;
private import dmdscript.script;
private import std.c.windows.windows;

version(Windows)
{
	pragma(lib,"dmdscript.lib");
	//pragma(lib,"phobos.lib");
}

extern (C)
{
	void gc_init();
	void gc_term();
	void _minit();
	void _moduleCtor();
	//void _moduleUnitTests();
}

static const char[] this_url="http://www.lessequal.com/xcdscript";
static const char[] this_name="DMDScript";
static const char[] this_desc="DMDScript-ing interface";
static const char[] this_version="1.0 RC1";

static const char[] xds_load_usage="Usage: /XDS_LOAD FILE";
static const char[] xds_load_name="XDS_LOAD";
static const char[] xds_unload_usage="Usage: /XDS_UNLOAD FILE";
static const char[] xds_unload_name="XDS_UNLOAD";
static const char[] xds_list_usage="Usage: /XDS_LIST";
static const char[] xds_list_name="XDS_LIST";
static const char[] xds_append_usage="Usage: /XDS_APPEND FILE";
static const char[] xds_append_name="XDS_APPEND";

static xchat_plugin *this_ph;

hookinfo[uint] x_hooks;
Program[char[]] x_scripts;
Program[CallContext*] x_callcontexts;
static uint hookid=0;

struct hookinfo
{
	Program *prog;
	uint id;
	char[] callback;
	xchat_hook *xhook;
}


//////////// dmdscript


void* g_xchat_hook_command(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,4,"xchat_hook_command");
	if(!v)
	{
		hookinfo hi;
		hi.prog=cc in x_callcontexts;
		hi.callback=arglist[2].toString();
		hi.id=++hookid;
		hi.xhook=this_ph.xchat_hook_command(this_ph,toStringz(arglist[0].toString()),arglist[1].toInt32(),&on_hook_cmd,arglist[3].toString(),cast(void*)hi.id);
		x_hooks[hi.id]=hi;
		ret.putVnumber(hi.id);
	}
	return v;
}

/*void* g_xchat_hook_fd(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	return null;
}*/

void* g_xchat_hook_print(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,3,"xchat_hook_print");
	if(!v)
	{
		hookinfo hi;
		hi.prog=cc in x_callcontexts;
		hi.callback=arglist[2].toString();
		hi.id=++hookid;
		hi.xhook=this_ph.xchat_hook_print(this_ph,toStringz(arglist[0].toString()),arglist[1].toInt32(),&on_hook_print,cast(void*)hi.id);
		x_hooks[hi.id]=hi;
		ret.putVnumber(hi.id);
	}
	return v;
}

void* g_xchat_hook_server(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,3,"xchat_hook_server");
	if(!v)
	{
		hookinfo hi;
		hi.prog=cc in x_callcontexts;
		hi.callback=arglist[2].toString();
		hi.id=++hookid;
		hi.xhook=this_ph.xchat_hook_server(this_ph,toStringz(arglist[0].toString()),arglist[1].toInt32(),&on_hook_cmd,cast(void*)hi.id);
		x_hooks[hi.id]=hi;
		ret.putVnumber(hi.id);
	}
	return v;
}

void* g_xchat_hook_timer(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,2,"xchat_hook_timer");
	if(!v)
	{
		hookinfo hi;
		hi.prog=cc in x_callcontexts;
		hi.callback=arglist[1].toString();
		hi.id=++hookid;
		hi.xhook=this_ph.xchat_hook_timer(this_ph,arglist[0].toInt32(),&on_hook_timer,cast(void*)hi.id);
		x_hooks[hi.id]=hi;
		ret.putVnumber(hi.id);
	}
	return v;
}

void* g_xchat_unhook(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_unhook");
	if(!v)
	{
		uint id=arglist[0].toUint32();
		hookinfo *hi=id in x_hooks;
		if(hi)
		{
			this_ph.xchat_unhook(this_ph,hi.xhook);
			x_hooks.remove(id);
		}
		else trace("xchat_unhook(): no such hook id "~std.string.toString(id));
	}
	return v;
}

void* g_xchat_command(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_command");
	if(!v) this_ph.xchat_command(this_ph,toStringz(arglist[0].toString()));
	return v;
}

//xchat_commandf

void* g_xchat_print(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_print");
	if(!v) trace(arglist[0].toString());
	return v;
}

//xchat_printf

void* g_xchat_emit_print(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	//todo: the whole arglist should be passed to the variadic function
	Value *v=getErrorReturn(arglist,1,"xchat_emit_print");
	if(!v)
	{
		if(arglist.length==1) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()));
		else if(arglist.length==2) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()));
		else if(arglist.length==3) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()));
		else if(arglist.length==4) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()));
		else if(arglist.length==5) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()));
		else if(arglist.length==6) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()));
		else if(arglist.length==7) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()));
		else if(arglist.length==8) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()));
		else if(arglist.length==9) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()));
		else if(arglist.length==10) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()));
		else if(arglist.length==11) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()));
		else if(arglist.length==12) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()));
		else if(arglist.length==13) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()));
		else if(arglist.length==14) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()));
		else if(arglist.length==15) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()));
		else if(arglist.length==16) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()));
		else if(arglist.length==17) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()));
		else if(arglist.length==18) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()));
		else if(arglist.length==19) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()));
		else if(arglist.length==20) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()));
		else if(arglist.length==21) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()));
		else if(arglist.length==22) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()));
		else if(arglist.length==23) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()));
		else if(arglist.length==24) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()));
		else if(arglist.length==25) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()));
		else if(arglist.length==26) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()));
		else if(arglist.length==27) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()),toStringz(arglist[26].toString()));
		else if(arglist.length==28) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()),toStringz(arglist[26].toString()),toStringz(arglist[27].toString()));
		else if(arglist.length==29) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()),toStringz(arglist[26].toString()),toStringz(arglist[27].toString()),toStringz(arglist[28].toString()));
		else if(arglist.length==30) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()),toStringz(arglist[26].toString()),toStringz(arglist[27].toString()),toStringz(arglist[28].toString()),toStringz(arglist[29].toString()));
		else if(arglist.length==31) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()),toStringz(arglist[26].toString()),toStringz(arglist[27].toString()),toStringz(arglist[28].toString()),toStringz(arglist[29].toString()),toStringz(arglist[30].toString()));
		else if(arglist.length==32) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()),toStringz(arglist[26].toString()),toStringz(arglist[27].toString()),toStringz(arglist[28].toString()),toStringz(arglist[29].toString()),toStringz(arglist[30].toString()),toStringz(arglist[31].toString()));
		else if(arglist.length==33) this_ph.xchat_emit_print(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString()),toStringz(arglist[2].toString()),toStringz(arglist[3].toString()),toStringz(arglist[4].toString()),toStringz(arglist[5].toString()),toStringz(arglist[6].toString()),toStringz(arglist[7].toString()),toStringz(arglist[8].toString()),toStringz(arglist[9].toString()),toStringz(arglist[10].toString()),toStringz(arglist[11].toString()),toStringz(arglist[12].toString()),toStringz(arglist[13].toString()),toStringz(arglist[14].toString()),toStringz(arglist[15].toString()),toStringz(arglist[16].toString()),toStringz(arglist[17].toString()),toStringz(arglist[18].toString()),toStringz(arglist[19].toString()),toStringz(arglist[20].toString()),toStringz(arglist[21].toString()),toStringz(arglist[22].toString()),toStringz(arglist[23].toString()),toStringz(arglist[24].toString()),toStringz(arglist[25].toString()),toStringz(arglist[26].toString()),toStringz(arglist[27].toString()),toStringz(arglist[28].toString()),toStringz(arglist[29].toString()),toStringz(arglist[30].toString()),toStringz(arglist[31].toString()),toStringz(arglist[32].toString()));
	}
	return v;
}

void* g_xchat_send_modes(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,4,"xchat_send_modes");
	if(!v)
	{
		char*[] names;
		Value *v;
		Dobject o;
		if(!arglist[0].isUndefinedOrNull())
		{
			o=arglist[0].toObject();
			if(o.isClass(TEXT_Array))
			{
				uint len=o.Get(TEXT_length).toUint32();
				for(uint c;c<len;c++)
				{
					v=o.Get(c);
					if(v) names~=toStringz(v.toString());
				}
			}
			else names~=toStringz(arglist[0].toString());
		}
		this_ph.xchat_send_modes(this_ph,names.ptr,names.length,arglist[1].toInt32(),arglist[2].toString()[0],arglist[3].toString()[0]);
	}
	return v;
}

void* g_xchat_get_info(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_get_info");
	if(!v)
	{
		char[] a=arglist[0].toString();
		char *b=this_ph.xchat_get_info(this_ph,toStringz(a));
		if(a=="win_ptr") ret.putVnumber(cast(int)b);
		else ret.putVstring(std.string.toString(b).dup);
	}
	return v;
}

void* g_xchat_get_prefs(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_get_prefs");
	if(!v)
	{
		char *ch;
		int i;
		int res=this_ph.xchat_get_prefs(this_ph,toStringz(arglist[0].toString()),&ch,&i);
		if(res==0) ret.putVundefined();
		else if(res==1) ret.putVstring(std.string.toString(ch).dup);
		else if(res==2) ret.putVnumber(i);
		else if(res==3) ret.putVboolean(i);
	}
	return v;
}

void* g_xchat_find_context(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	xchat_context *re=this_ph.xchat_find_context(this_ph,arglist.length>=1?(arglist[0].isUndefinedOrNull()?null:toStringz(arglist[0].toString())):null,arglist.length>=2?(arglist[1].isUndefinedOrNull()?null:toStringz(arglist[1].toString())):null);
	if(re) ret.putVnumber(cast(int)re);
	else ret.putVnull();
	return null;
}

void* g_xchat_get_context(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	xchat_context *re=this_ph.xchat_get_context(this_ph);
	if(re) ret.putVnumber(cast(int)re);
	else ret.putVnull();
	return null;
}

void* g_xchat_set_context(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_set_context");
	if(!v) ret.putVnumber(this_ph.xchat_set_context(this_ph,cast(xchat_context*)arglist[0].toInt32()));
	return v;
}

void* g_xchat_nickcmp(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,2,"xchat_nickcmp");
	if(!v) ret.putVnumber(this_ph.xchat_nickcmp(this_ph,toStringz(arglist[0].toString()),toStringz(arglist[1].toString())));
	return v;
}

void* g_xchat_strip(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_strip");
	if(!v)
	{
		char[] a=arglist[0].toString();
		int b=arglist.length>1?arglist[1].toInt32():3;
		char *r=this_ph.xchat_strip(this_ph,a.ptr,a.length,b);
		ret.putVstring(std.string.toString(r).dup);
		this_ph.xchat_free(this_ph,r);
	}
	return v;
}

//useless
//void* g_xchat_free(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist){return null;}

void* g_xchat_list_get(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist)
{
	Value *v=getErrorReturn(arglist,1,"xchat_list_get");
	if(!v)
	{
		char[] a=arglist[0].toString();
		if(a=="dcc")
		{
			xchat_list *list = this_ph.xchat_list_get(this_ph,toStringz(a));
			if(list)
			{
				Darray a=new Darray;
				Dobject o=new Dobject(null);
				Value *v=new Value;
				int c;
				while(this_ph.xchat_list_next(this_ph,list))
				{
					o.Put("destfile",std.string.toString(this_ph.xchat_list_str(this_ph,list,"destfile")),0);
					o.Put("file",std.string.toString(this_ph.xchat_list_str(this_ph,list,"file")),0);
					o.Put("nick",std.string.toString(this_ph.xchat_list_str(this_ph,list,"nick")),0);
					o.Put("cps",this_ph.xchat_list_int(this_ph,list,"cps"),0);
					o.Put("pos",this_ph.xchat_list_int(this_ph,list,"pos"),0);
					o.Put("address32",this_ph.xchat_list_int(this_ph,list,"address32"),0);
					o.Put("port",this_ph.xchat_list_int(this_ph,list,"port"),0);
					o.Put("resume",this_ph.xchat_list_int(this_ph,list,"resume"),0);
					o.Put("size",this_ph.xchat_list_int(this_ph,list,"size"),0);
					o.Put("status",this_ph.xchat_list_int(this_ph,list,"status"),0);
					o.Put("type",this_ph.xchat_list_int(this_ph,list,"type"),0);
					v.putVobject(o);
					a.Put(c++,v,0);
				}
				this_ph.xchat_list_free(this_ph,list);
				if(c) ret.putVobject(a);
				else ret.putVnull();
			}
			else ret.putVnull();
		}
		else if(a=="users")
		{
			xchat_list *list = this_ph.xchat_list_get(this_ph,toStringz(a));
			if(list)
			{
				Darray a=new Darray;
				Dobject o=new Dobject(null);
				Value *v=new Value;
				int c;
				while(this_ph.xchat_list_next(this_ph,list))
				{
					o.Put("host",std.string.toString(this_ph.xchat_list_str(this_ph,list,"host")),0);
					o.Put("prefix",std.string.toString(this_ph.xchat_list_str(this_ph,list,"prefix")),0);
					o.Put("nick",std.string.toString(this_ph.xchat_list_str(this_ph,list,"nick")),0);
					o.Put("away",this_ph.xchat_list_int(this_ph,list,"away"),0);
					o.Put("lasttalk",this_ph.xchat_list_time(this_ph,list,"lasttalk"),0);
					v.putVobject(o);
					a.Put(c++,v,0);
				}
				this_ph.xchat_list_free(this_ph,list);
				if(c) ret.putVobject(a);
				else ret.putVnull();
			}
			else ret.putVnull();
		}
		else if(a=="notify")
		{
			xchat_list *list = this_ph.xchat_list_get(this_ph,toStringz(a));
			if(list)
			{
				Darray a=new Darray;
				Dobject o=new Dobject(null);
				Value *v=new Value;
				int c;
				while(this_ph.xchat_list_next(this_ph,list))
				{
					o.Put("nick",std.string.toString(this_ph.xchat_list_str(this_ph,list,"nick")),0);
					o.Put("flags",this_ph.xchat_list_int(this_ph,list,"flags"),0);
					o.Put("on",this_ph.xchat_list_time(this_ph,list,"on"),0);
					o.Put("off",this_ph.xchat_list_time(this_ph,list,"off"),0);
					o.Put("seen",this_ph.xchat_list_time(this_ph,list,"seen"),0);
					v.putVobject(o);
					a.Put(c++,v,0);
				}
				this_ph.xchat_list_free(this_ph,list);
				if(c) ret.putVobject(a);
				else ret.putVnull();
			}
			else ret.putVnull();
		}
		else if(a=="ignore")
		{
			xchat_list *list = this_ph.xchat_list_get(this_ph,toStringz(a));
			if(list)
			{
				Darray a=new Darray;
				Dobject o=new Dobject(null);
				Value *v=new Value;
				int c;
				while(this_ph.xchat_list_next(this_ph,list))
				{
					o.Put("mask",std.string.toString(this_ph.xchat_list_str(this_ph,list,"mask")),0);
					o.Put("flags",this_ph.xchat_list_int(this_ph,list,"flags"),0);
					v.putVobject(o);
					a.Put(c++,v,0);
				}
				this_ph.xchat_list_free(this_ph,list);
				if(c) ret.putVobject(a);
				else ret.putVnull();
			}
			else ret.putVnull();
		}
		else if(a=="channels")
		{
			xchat_list *list = this_ph.xchat_list_get(this_ph,toStringz(a));
			if(list)
			{
				Darray a=new Darray;
				Dobject o=new Dobject(null);
				Value *v=new Value;
				int c;
				while(this_ph.xchat_list_next(this_ph,list))
				{
					o.Put("channel",std.string.toString(this_ph.xchat_list_str(this_ph,list,"mask")),0);
					o.Put("chantypes",std.string.toString(this_ph.xchat_list_str(this_ph,list,"chantypes")),0);
					o.Put("context",cast(int)this_ph.xchat_list_str(this_ph,list,"context"),0);
					o.Put("network",std.string.toString(this_ph.xchat_list_str(this_ph,list,"network")),0);
					o.Put("nickprefixes",std.string.toString(this_ph.xchat_list_str(this_ph,list,"nickprefixes")),0);
					o.Put("nickmodes",std.string.toString(this_ph.xchat_list_str(this_ph,list,"nickmodes")),0);
					o.Put("server",std.string.toString(this_ph.xchat_list_str(this_ph,list,"server")),0);
					o.Put("flags",this_ph.xchat_list_int(this_ph,list,"flags"),0);
					o.Put("id",this_ph.xchat_list_int(this_ph,list,"id"),0);
					o.Put("maxmodes",this_ph.xchat_list_int(this_ph,list,"maxmodes"),0);
					o.Put("type",this_ph.xchat_list_int(this_ph,list,"type"),0);
					o.Put("users",this_ph.xchat_list_int(this_ph,list,"users"),0);
					v.putVobject(o);
					a.Put(c++,v,0);
				}
				this_ph.xchat_list_free(this_ph,list);
				if(c) ret.putVobject(a);
				else ret.putVnull();
			}
			else ret.putVnull();
		}
		else ret.putVundefined();
	}
	return v;
}

//useless
//void* g_xchat_list_free(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist){return null;}
//xchat_list_fields (not documented yet)
//void* g_xchat_list_next(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist){return null;}
//void* g_xchat_list_str(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist){return null;}
//void* g_xchat_list_int(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist){return null;}
//void* g_xchat_list_time(Dobject pthis,CallContext* cc,Dobject othis,Value* ret,Value[] arglist){return null;}

//xchat_plugingui_add (not documented yet)
//xchat_plugingui_remove (not documented yet)


Value *getErrorReturn(Value[] arglist,int minarguments,char[] name)
{
	Value *v=null;
	if(arglist.length<minarguments)
	{
		v=new Value;
		char[] str="Insufficient number of arguments for "~name~"() - "~std.string.toString(arglist.length)~"/"~std.string.toString(minarguments);
		v.putVstring(str);
		trace(str);
	}
	return v;
}

void *eval(Program prog,char[] argument,Value *ret=new Value)
{
	Value[] getEvalArgument(char[] argument)
	{
		Value[] args;
		args.length=1;
		args[0]=*new Value;
		args[0].putVstring(argument);
		return args;
	}

	return Dglobal_eval(null,prog.callcontext,prog.callcontext.global,ret,getEvalArgument(argument));
}

static char[] gt_xchat_hook_command="xchat_hook_command";
static char[] gt_xchat_hook_fd="xchat_hook_fd";
static char[] gt_xchat_hook_print="xchat_hook_print";
static char[] gt_xchat_hook_server="xchat_hook_server";
static char[] gt_xchat_hook_timer="xchat_hook_timer";
static char[] gt_xchat_unhook="xchat_unhook";
static char[] gt_xchat_command="xchat_command";
//xchat_commandf
static char[] gt_xchat_print="xchat_print";
//xchat_printf
static char[] gt_xchat_emit_print="xchat_emit_print";
static char[] gt_xchat_send_modes="xchat_send_modes";
static char[] gt_xchat_find_context="xchat_find_context";
static char[] gt_xchat_get_context="xchat_get_context";
static char[] gt_xchat_get_info="xchat_get_info";
static char[] gt_xchat_get_prefs="xchat_get_prefs";
static char[] gt_xchat_set_context="xchat_set_context";
static char[] gt_xchat_nickcmp="xchat_nickcmp";
static char[] gt_xchat_strip="xchat_strip";
//static char[] gt_xchat_free="xchat_free";
static char[] gt_xchat_list_get="xchat_list_get";
//static char[] gt_xchat_list_free="xchat_list_free";
//xchat_list_fields (not documented yet)
//static char[] gt_xchat_list_next="xchat_list_next";
//static char[] gt_xchat_list_str="xchat_list_str";
//static char[] gt_xchat_list_int="xchat_list_int";
//static char[] gt_xchat_list_time="xchat_list_time";
//xchat_plugingui_add (not documented yet)
//xchat_plugingui_remove (not documented yet)

static NativeFunctionData nfd_xchat[] =[
	{&gt_xchat_hook_command,&g_xchat_hook_command,1},
//	{&gt_xchat_hook_fd,&g_xchat_hook_fd,1},
	{&gt_xchat_hook_print,&g_xchat_hook_print,1},
	{&gt_xchat_hook_server,&g_xchat_hook_server,1},
	{&gt_xchat_hook_timer,&g_xchat_hook_timer,1},
	{&gt_xchat_unhook,&g_xchat_unhook,1},
	{&gt_xchat_command,&g_xchat_command,1},
//	xchat_commandf
	{&gt_xchat_print,&g_xchat_print,1},
//	xchat_printf
	{&gt_xchat_emit_print,&g_xchat_emit_print,1},
	{&gt_xchat_send_modes,&g_xchat_send_modes,1},
	{&gt_xchat_find_context,&g_xchat_find_context,1},
	{&gt_xchat_get_context,&g_xchat_get_context,1},
	{&gt_xchat_get_info,&g_xchat_get_info,1},
	{&gt_xchat_get_prefs,&g_xchat_get_prefs,1},
	{&gt_xchat_set_context,&g_xchat_set_context,1},
	{&gt_xchat_nickcmp,&g_xchat_nickcmp,1},
	{&gt_xchat_strip,&g_xchat_strip,1},
//	{&gt_xchat_free,&g_xchat_free,1},
	{&gt_xchat_list_get,&g_xchat_list_get,1},
//	{&gt_xchat_list_free,&g_xchat_list_free,1},
//	xchat_list_fields (not documented yet)
//	{&gt_xchat_list_next,&g_xchat_list_next,1},
//	{&gt_xchat_list_str,&g_xchat_list_str,1},
//	{&gt_xchat_list_int,&g_xchat_list_int,1},
//	{&gt_xchat_list_time,&g_xchat_list_time,1},
//	xchat_plugingui_add (not documented yet)
//	xchat_plugingui_remove (not documented yet)
];

////////////////////////////////////////////


void trace(char[] text){this_ph.xchat_print(this_ph,toStringz(text));}
//void trace(char *text){this_ph.xchat_print(this_ph,text);}


////////////// xchat

extern(C) static int on_hook_print(char **word, void *userdata)
{
	return on_hook_cmd(word,null,userdata);
}

extern(C) static int on_hook_timer(void *userdata)
{
	return on_hook_cmd(null,null,userdata);
}

extern(C) static int on_hook_cmd(char **word, char **word_eol, void *userdata)
{
	uint id=cast(uint)userdata;
	hookinfo *hi=id in x_hooks;
	if(hi)
	{
		Value *ret=new Value;
		char[][] ar;
		if(word) for(int c=1;c<32;c++)
		{
			char *a=word[c];
			if(!a) break;
			if(!a[0]) continue;
			ar~=replace(replace(std.string.toString(a).dup,"\\","\\\\"),"\"","\\\"");
		}
		eval(*hi.prog,hi.callback~"("~((ar.length)?('"'~join(ar,"\",\"")~'"'):"")~");",ret);
		return ret.toInt32();
	}
	return XCHAT_EAT_NONE;
}

extern(C) static int cb_xds_load(char **word, char **word_eol, void *userdata)
{
	void[] buffer;
	char[] path=std.string.toString(word[2]).dup;
	if(!path.length) trace("XDS_LOAD: Enter file to load.");
	else if(path in x_scripts) trace("XDS_LOAD: File is already loaded ("~path~").");
	else if(!exists(path)) trace("XDS_LOAD: File does not exists ("~path~").");
	else
	{
		buffer=read(path);
		Program prog=new Program;
		DnativeFunction.init(prog.callcontext.global,nfd_xchat,DontEnum);
		prog.callcontext.global.Put("XCHAT_PRI_HIGHEST",127, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_PRI_HIGH",64, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_PRI_NORM",0, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_PRI_LOW",-64, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_PRI_LOWEST",-128, DontEnum|DontDelete|ReadOnly);
		//prog.callcontext.global.Put("XCHAT_FD_READ",1, DontEnum|DontDelete|ReadOnly);
		//prog.callcontext.global.Put("XCHAT_FD_WRITE",2, DontEnum|DontDelete|ReadOnly);
		//prog.callcontext.global.Put("XCHAT_FD_EXCEPTION",4, DontEnum|DontDelete|ReadOnly);
		//prog.callcontext.global.Put("XCHAT_FD_NOTSOCKET",8, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_EAT_NONE",0, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_EAT_XCHAT",1, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_EAT_PLUGIN",2, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("XCHAT_EAT_ALL",3, DontEnum|DontDelete|ReadOnly);
		prog.callcontext.global.Put("SCRIPT_PATH",path, DontEnum|DontDelete|ReadOnly);
		x_scripts[path]=prog;
		x_callcontexts[prog.callcontext]=prog;
		try
		{
			prog.compile(path,cast(char[])buffer,null);
			prog.execute(null);
			eval(prog,"xchat_plugin_init();");
		}
		catch (Object o){trace("DMDScript exception ("~path~"): "~o.toString());}
	}

	return XCHAT_EAT_ALL;
}

extern(C) static int cb_xds_unload(char **word, char **word_eol, void *userdata)
{
	char[] path=std.string.toString(word[2]);
	if(!path.length) trace("XDS_UNLOAD: Enter file to unload.");
	else
	{
		Program *prog=path in x_scripts;
		if(!prog) trace("XDS_UNLOAD: File is not loaded ("~path~").");
		else
		{
			x_scripts.remove(path);
			CallContext*[Program] t;
			foreach(CallContext *c,Program p;x_callcontexts) t[p]=c;
			t.rehash;
			foreach(uint id,hookinfo hi;x_hooks)
			{
				if(*hi.prog is *prog)
				{
					this_ph.xchat_unhook(this_ph,hi.xhook);
					x_hooks.remove(id);
					x_callcontexts.remove(t[*prog]);
					t.remove(*prog);
				}
			}
			eval(*prog,"xchat_plugin_deinit();");
		}
	}

	return XCHAT_EAT_ALL;
}

extern(C) static int cb_xds_list(char **word, char **word_eol, void *userdata)
{
	trace("Listing loaded DMDScript-s:\n");
	int c;
	foreach(char[] a;x_scripts.keys)
	{
		c++;
		trace(std.string.toString(c)~". "~a~"\n");
	}
	trace("End of list");

	return XCHAT_EAT_ALL;
}

extern(C) static int cb_xds_append(char **word, char **word_eol, void *userdata)
{
	char[] p=std.string.toString(word[2]);
	trace("XDS_APPEND: "~p);
	std.file.append(autoloadpath,"\n"~p);
	return XCHAT_EAT_ALL;
}

version(Windows) extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
    switch (ulReason)
    {
	case DLL_PROCESS_ATTACH:
	    gc_init();			// initialize GC
	    _minit();			// initialize module list
	    _moduleCtor();		// run module constructors
	    //_moduleUnitTests();		// run module unit tests
	    break;

	case DLL_PROCESS_DETACH:
	    gc_term();			// shut down GC
	    break;

	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	    // Multiple threads not supported yet
	    return false;
	default: ;
    }
    return true;
}

char[] autoloadpath;

export extern(C) int xchat_plugin_deinit(){return 1;}
export extern(C) int xchat_plugin_init(xchat_plugin *plugin_handle,char **plugin_name,char **plugin_desc,char **plugin_version,char *arg)
{
	this_ph=plugin_handle;
	*plugin_name = this_name.ptr;*plugin_desc = this_desc.ptr;*plugin_version = this_version.ptr;
	trace("\nLoading "~this_name~".\n"~this_url);

	this_ph.xchat_hook_command(this_ph,toStringz(xds_load_name),XCHAT_PRI_NORM,&cb_xds_load,toStringz(xds_load_usage),null);
	this_ph.xchat_hook_command(this_ph,toStringz(xds_unload_name),XCHAT_PRI_NORM,&cb_xds_unload,toStringz(xds_unload_usage),null);
	this_ph.xchat_hook_command(this_ph,toStringz(xds_list_name),XCHAT_PRI_NORM,&cb_xds_list,toStringz(xds_list_usage),null);
	this_ph.xchat_hook_command(this_ph,toStringz(xds_append_name),XCHAT_PRI_NORM,&cb_xds_append,toStringz(xds_append_usage),null);

	autoloadpath=std.string.toString(this_ph.xchat_get_info(this_ph,"xchatdirfs")).dup~"/xcdscript.txt";
	if(exists(autoloadpath))
	{
		File f=new File(autoloadpath,FileMode.In);
		for(char[] p=f.readLine();p.length;p=f.readLine()) {this_ph.xchat_command(this_ph,toStringz(xds_load_name~" \""~p~"\""));}
		f.close();
	}

	trace(this_name~" loaded.");
	return 1;
}
