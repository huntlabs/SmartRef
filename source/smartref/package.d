module smartref;

public import smartref.scopedref;
public import smartref.sharedref;
import smartref.util;

import std.experimental.allocator;

auto makeSharedRef(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	Pointer!T value = make!T(alloc,args);
	static if(stateSize!Alloc == 0){
		return SharedRef!(Alloc,T)(value);
	} else {
		return SharedRef!(Alloc,T)(alloc,value);
	}
}

auto makeSingleSharedRef(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	Pointer!T value = make!T(alloc,args);
	static if(stateSize!Alloc == 0){
		return SharedRef!(Alloc,T,false)(value);
	} else {
		return SharedRef!(Alloc,T,false)(alloc,value);
	}
}

auto makeScopedRef(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	Pointer!T value = make!T(alloc,args);
	static if(stateSize!Alloc == 0){
		return ScopedRef!(Alloc,T)(value);
	} else {
		return ScopedRef!(Alloc,T)(alloc,value);
	}
}

auto makeSharedRefWithDeleter(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref Alloc,Pointer!T) nothrow));
	Pointer!T value = make!T(alloc,args[1..$]);
	static if(stateSize!Alloc == 0){
		return SharedRef!(Alloc,T)(value,args[0]);
	} else {
		return SharedRef!(Alloc,T)(alloc,value,args[0]);
	}
}

auto makeSingleSharedRefWithDeleter(T,Alloc,Args...)(auto ref  Alloc alloc,auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref Alloc,Pointer!T) nothrow));
	Pointer!T value = make!T(alloc,args[1..$]);
	static if(stateSize!Alloc == 0){
		return SharedRef!(Alloc,T,false)(value,args[0]);
	} else {
		return SharedRef!(Alloc,T,false)(alloc,value,args[0]);
	}
}

auto makeScopedRefWithDeleter(T,Alloc,Args...)(auto ref  Alloc alloc,auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref Alloc,Pointer!T) nothrow));
	Pointer!T value = make!T(alloc,args[1..$]);
	static if(stateSize!Alloc == 0){
		return ScopedRef!(Alloc,T)(value,args[0]);
	} else {
		return ScopedRef!(Alloc,T)(alloc,value,args[0]);
	}
}
