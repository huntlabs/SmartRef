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

auto makeSharedRefWithDeleter(T,Alloc,Args...)(auto ref Alloc alloc,auto ref void function(ref Alloc,Pointer!T) nothrow deleter,auto ref Args args){
	Pointer!T value = make!T(alloc,args);
	static if(stateSize!Alloc == 0){
		return SharedRef!(Alloc,T)(value,deleter);
	} else {
		return SharedRef!(Alloc,T)(alloc,value,deleter);
	}
}

auto makeSingleSharedRefWithDeleter(T,Alloc,Args...)(auto ref  Alloc alloc,auto ref void function(ref Alloc,Pointer!T) nothrow deleter,auto ref Args args){
	Pointer!T value = make!T(alloc,args);
	static if(stateSize!Alloc == 0){
		return SharedRef!(Alloc,T,false)(value,deleter);
	} else {
		return SharedRef!(Alloc,T,false)(alloc,value,deleter);
	}
}

auto makeScopedRefWithDeleter(T,Alloc,Args...)(auto ref  Alloc alloc,auto ref void function(ref Alloc,Pointer!T) nothrow deleter,auto ref Args args){
	Pointer!T value = make!T(alloc,args);
	static if(stateSize!Alloc == 0){
		return ScopedRef!(Alloc,T)(value,deleter);
	} else {
		return ScopedRef!(Alloc,T)(alloc,value,deleter);
	}
}
