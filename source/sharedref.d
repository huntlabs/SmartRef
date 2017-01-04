module sharedref;

import core.atomic;
import std.experimental.allocator;

struct SharedRef(Alloc,T,bool isShared)
{
	alias ValueType = Pointer!T;
	alias Deleter = void function(ValueType) nothrow;
	alias Data = ExternalRefCountData!(ValueType,isShared);

	this(ValueType ptr){}
	this(ValueType ptr,Deleter deleter){}

private:
	void deref() nothrow
	{
		if (!_dd) return;
		if (!_dd.strongDef()) {
			auto data = _dd.value;
			_dd.value = null;
			if(data){
				if(_deleter) 
					_deleter(data);
				else {
					dispose(_alloc,data);
				}
			}
		}
		if (!_dd.weakDef()){
			dispose(_alloc,_dd);
			_dd = null;
		}

	}

	Data _dd;
	Deleter _deleter;
	Alloc _alloc;
}


struct WeakRef(Alloc,T,bool isShared)
{
	alias ValueType = Pointer!T;
	alias Data = ExternalRefCountData!(ValueType,isShared);


private:
	void deref() nothrow
	{
		if (!_dd) return;
		if (!_dd.weakDef()){
			dispose(_alloc,_dd);
			_dd = null;
		}
	}

	Data _dd;
	Alloc _alloc;
}

private:

final class ExternalRefCountData(ValueType,bool isShared)
{
	ValueType value;
	pragma(inline,true)
	int strongDef(){
		static if(isShared)
			return atomicOp!("-=")(_strongref,1);
		else 
			return -- _strongref;
	}
	pragma(inline,true)
	int strongRef(){
		static if(isShared)
			return atomicOp!("+=")(_strongref,1);
		else
			return ++ _strongref;
	}
	pragma(inline,true)
	int weakDef(){
		static if(isShared)
			return atomicOp!("-=")(_weakref,1);
		else
			return -- _weakref;
	}
	pragma(inline,true)
	int weakRef(){
		static if(isShared)
			return atomicOp!("+=")(_weakref,1);
		else
			return ++ _weakref;
	}

	pragma(inline,true)
	@property weakref(){
		static if(isShared)
			return atomicLoad(_weakref);
		else
			return _weakref;
	}

	pragma(inline,true)
	@property strongref(){
		static if(isShared)
			return atomicLoad(_strongref);
		else
			return _strongref;
	}
private:
	static if(isShared){
		shared int _weakref = 1;
		shared int _strongref = 1;
	} else {
		int _weakref = 1;
		int _strongref = 1;
	}
}

template Pointer(T) {
	static if(is(T == class) || is(T == class)){
		alias Pointer = T;
	} else {
		alias Pointer = T *;
	}
}