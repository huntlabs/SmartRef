module smartref;

import std.experimental.allocator;

public import smartref.scopedref;
public import smartref.sharedref;
public import smartref.common;
import smartref.util;

alias SharedRef(T, bool isShared = true) = ISharedRef!(typeof(SmartGCAllocator.instance),T,isShared);
alias WeakRef(T, bool isShared = true) = IWeakRef!(typeof(SmartGCAllocator.instance),T,isShared);
alias EnableSharedFromThis(T, bool isShared = true) = IEnableSharedFromThis!(typeof(SmartGCAllocator.instance),T,isShared);
alias ScopedRef(T) = IScopedRef!(typeof(SmartGCAllocator.instance),T);

// alias
auto makeSharedRef(T,Args...)(auto ref Args args){
	return SharedRef!(T)(SmartGCAllocator.instance.make!T(args));
}

auto makeSingSharedRef(T,Args...)(auto ref Args args){
	return SharedRef!(T,false)(SmartGCAllocator.instance.make!T(args));
}

auto makeScopedRef(T,Args...)(auto ref Args args){
	return ScopedRef!(T)(SmartGCAllocator.instance.make!T(args));
}

auto makeSharedRefWithDeleter(T,Args...)(auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref typeof(SmartGCAllocator.instance),Pointer!T) nothrow));
	return SharedRef!(T)(SmartGCAllocator.instance.make!T(args[1..$]),args[0]);
}


auto makeSingleSharedRefWithDeleter(T,Args...)(auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref typeof(SmartGCAllocator.instance),Pointer!T) nothrow));
	return SharedRef!(T,false)(SmartGCAllocator.instance.make!T(args[1..$]),args[0]);
}

auto makeScopedRefWithDeleter(T,Args...)(auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref typeof(SmartGCAllocator.instance),Pointer!T) nothrow));
	return ScopedRef!(T)(SmartGCAllocator.instance.make!T(args[1..$]),args[0]);
}

// I
auto makeISharedRef(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	Pointer!T value = alloc.make!T(args);
	static if(stateSize!Alloc == 0){
		return ISharedRef!(Alloc,T)(value);
	} else {
		return ISharedRef!(Alloc,T)(alloc,value);
	}
}

auto makeSinglISharedRef(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	Pointer!T value = alloc.make!T(args);
	static if(stateSize!Alloc == 0){
		return ISharedRef!(Alloc,T,false)(value);
	} else {
		return ISharedRef!(Alloc,T,false)(alloc,value);
	}
}

auto makeIScopedRef(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	Pointer!T value = alloc.make!T(args);
	static if(stateSize!Alloc == 0){
		return IScopedRef!(Alloc,T)(value);
	} else {
		return IScopedRef!(Alloc,T)(alloc,value);
	}
}

auto makeISharedRefWithDeleter(T,Alloc,Args...)(auto ref Alloc alloc,auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref Alloc,Pointer!T) nothrow));
	Pointer!T value = alloc.make!T(args[1..$]);
	static if(stateSize!Alloc == 0){
		return ISharedRef!(Alloc,T)(value,args[0]);
	} else {
		return ISharedRef!(Alloc,T)(alloc,value,args[0]);
	}
}

auto makeSingleISharedRefWithDeleter(T,Alloc,Args...)(auto ref  Alloc alloc,auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref Alloc,Pointer!T) nothrow));
	Pointer!T value = alloc.make!T(args[1..$]);
	static if(stateSize!Alloc == 0){
		return ISharedRef!(Alloc,T,false)(value,args[0]);
	} else {
		return ISharedRef!(Alloc,T,false)(alloc,value,args[0]);
	}
}

auto makeIScopedRefWithDeleter(T,Alloc,Args...)(auto ref  Alloc alloc,auto ref Args args){
	static assert(args.length > 0);
	static assert(is(typeof(args[0]) == void function(ref Alloc,Pointer!T) nothrow));
	Pointer!T value = alloc.make!T(args[1..$]);
	static if(stateSize!Alloc == 0){
		return IScopedRef!(Alloc,T)(value,args[0]);
	} else {
		return IScopedRef!(Alloc,T)(alloc,value,args[0]);
	}
}
