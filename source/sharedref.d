module sharedref;

import core.atomic;
import std.experimental.allocator;
static import std.algorithm.mutation;
import std.traits;
import std.exception;
import util;

struct SharedRef(Alloc,T,bool isShared = true)
{
	alias ValueType = Pointer!T;
	alias Deleter = void function(ref Alloc,ValueType) nothrow;
	alias Data = ExternalRefCountData!(Alloc,ValueType,isShared);
	alias TWeakRef = WeakRef!(Alloc,T,isShared);
	alias TSharedRef = SharedRef!(Alloc,T,isShared);
	static if(is(T == class)){
		alias QEnableSharedFromThis = EnableSharedFromThis!(Alloc,T,isShared);
	}
	enum isSaticAlloc = (stateSize!Alloc == 0);

	static if(isSaticAlloc) {
		this(ValueType ptr){
			internalConstruct(ptr,&defaultDeleter);
		}
		this(ValueType ptr,Deleter deleter){
			internalConstruct(ptr,deleter);
		}
	} else {
		this(Alloc alloc ,ValueType ptr){
			_alloc = alloc;
			internalConstruct(ptr,&defaultDeleter);
		}
		this(Alloc alloc ,ValueType ptr,Deleter deleter){
			_alloc = alloc;
			internalConstruct(ptr,deleter);
		}

		@property Alloc allocator(){return _alloc;}
	}

	this(ref TSharedRef sptr){
		this._ptr = sptr._ptr;
		this._dd = sptr._dd;
		if(_dd) {
			_dd.strongRef();
			_dd.weakRef();
		}
		static if(!isSaticAlloc)
			this._alloc = tref._alloc;
	}

	this(ref TWeakRef wptr){
		internalSet(wptr._dd,wptr._alloc);
	}

	~this(){deref();}

	@property ValueType data() {return _ptr;}
	@property bool isNull()const {return (_ptr is null);}

	pragma(inline)
	void swap(ref TSharedRef tref){
		std.algorithm.mutation.swap(tref._dd,this._dd);
		std.algorithm.mutation.swap(tref._ptr,this._ptr);
		static if(!isSaticAlloc)
			std.algorithm.mutation.swap(tref._alloc,this._alloc);
	}
	pragma(inline,true) void rest(){clear();}
	pragma(inline) void clear() { TSharedRef copy = TSharedRef.init; swap(copy);}
	static if(isSaticAlloc) {
		pragma(inline,true) void rest()(ValueType ptr){
			TSharedRef copy = TSharedRef(ptr); swap(copy);
		}
		pragma(inline,true) void rest()(ValueType ptr,Deleter deleter){
			TSharedRef copy = TSharedRef(ptr,deleter); swap(copy);
		}
	} else {
		pragma(inline,true) void rest()(Alloc alloc ,ValueType ptr){
			TSharedRef copy = TSharedRef(alloc,ptr); swap(copy);
		}
		pragma(inline,true) void rest()(Alloc alloc ,ValueType ptr,Deleter deleter){
			TSharedRef copy = TSharedRef(alloc,ptr,deleter); swap(copy);
		}
	}

	TWeakRef toWeakRef() {
		return TWeakRef(this);
	}

	void opAssign(ref TSharedRef rhs){
		TSharedRef copy = TSharedRef(rhs);
		swap(copy);
	}

	void opAssign(ref TWeakRef rhs){
		internalSet(rhs._dd,rhs._alloc);
	}

	static if (isPointer!ValueType) {
		ref T opUnary(string op)()
			if (op == "*")
		{
			return *_ptr;
		}
	}

private:

	static void defaultDeleter(ref Alloc alloc, ValueType value) nothrow {
		 collectException( alloc.dispose(value) );
	}

	void deref() nothrow{
		_ptr = null;
		deref(_dd,_alloc);
	}
	static void deref(ref Data dd, ref Alloc alloc) nothrow{
		if (!dd) return;
		if (!dd.strongDef()) {
			dd.free(alloc);
		}
		if (!dd.weakDef()){
			collectException(alloc.dispose(dd));
			dd = null;
		}
	}
	void internalConstruct(ValueType ptr, Deleter deleter)
	{
		_ptr = ptr;
		if(ptr !is null) {
			_dd = _alloc.make!(Data)(ptr,deleter);
			static if(is(T == class) && isInheritClass(T,QEnableSharedFromThis))
				ptr.initializeFromSharedPointer(this);
		}
	}

	void internalSet(Data o,ref Alloc alloc){
		static if(!isSaticAlloc) {
			Alloc tmpalloc = _alloc;
			_alloc = alloc;
		} else {
			alias tmpalloc = Alloc.instance;
		}
		if(o){
			if(o.strongref > 0){
				o.strongRef();
				o.weakRef();
				_ptr = o.value;
			} else {
				_ptr = null;
				o = null;
			}
		}
		std.algorithm.mutation.swap(_dd,o);
		deref(o,tmpalloc);
	}
	ValueType _ptr;// 只为保留指针在栈中，如果指针是GC分配的内存，而ExternalRefCountData非GC的，则不用把非GC内存添加到GC的扫描列表中
	Data _dd;
	static if(!isSaticAlloc)
		Alloc _alloc ;
	else
		alias _alloc = Alloc.instance;
}

struct WeakRef(Alloc,T,bool isShared = true)
{
	alias ValueType = Pointer!T;
	alias Data = ExternalRefCountData!(Alloc,ValueType,isShared);
	enum isSaticAlloc = (stateSize!Alloc == 0);
	alias TWeakRef = WeakRef!(Alloc,T,isShared);
	alias TSharedRef = SharedRef!(Alloc,T,isShared);

	this(ref TSharedRef tref){
		this._ptr = tref._ptr;
		this._dd = tref._dd;
		if(_dd) _dd.weakRef();
		static if(!isSaticAlloc)
			this._alloc = tref._alloc; 
	}

	this(ref TWeakRef tref){
		this._ptr = tref._ptr;
		this._dd = tref._dd;
		if(_dd) _dd.weakRef();
		static if(!isSaticAlloc)
			this._alloc = tref._alloc;
	}

	pragma(inline,true) bool isNull() { return (_dd is null || _ptr is null ||  _dd.value is null || _dd.strongref == 0); }
	pragma(inline,true) ValueType data() { return isNull()  ? null : _ptr; }
	pragma(inline) void swap(ref TWeakRef tref) 
	{
		std.algorithm.mutation.swap(tref._dd,this._dd);
		std.algorithm.mutation.swap(tref._ptr,this._ptr);
		static if(!isSaticAlloc)
			std.algorithm.mutation.swap(tref._alloc,this._alloc);
	}

	pragma(inline,true) TSharedRef toStrongRef()  { return TSharedRef(this); }

	void opAssign(ref TWeakRef rhs){
		TWeakRef copy = TWeakRef(rhs);
		swap(copy);
	}
	
	void opAssign(ref TSharedRef rhs){
		internalSet(rhs._dd,rhs._alloc);
	}
private:
	void deref() nothrow
	{
		_ptr = null;
		if (!_dd) return;
		if (!_dd.weakDef()){
			collectException(_alloc.dispose(_dd));
			_dd = null;
		}
	}

	void internalSet(Data o,ref Alloc alloc){
		if (_dd is o) return;
		if (o) {
			o.weakRef();
			_ptr = o.value;
		}
		if (_dd && !_dd.weakDef())
			_alloc.dispose(_dd);
		_dd = o;
		static if(!isSaticAlloc) 
			_alloc = alloc;
	}
	
	ValueType _ptr; // 只为保留指针在栈中，如果指针是GC分配的内存，而ExternalRefCountData非GC的，则不用把非GC内存添加到GC的扫描列表中
	Data _dd;
	static if(!isSaticAlloc)
		Alloc _alloc;
	else
		alias _alloc = Alloc.instance;
}

abstract class EnableSharedFromThis(Alloc,T,bool isShared = true)
{
	alias TWeakRef = WeakRef!(Alloc,T,isShared);
	alias TSharedRef = SharedRef!(Alloc,T,isShared);

	pragma(inline,true)
	final TSharedRef sharedFromThis() { return TSharedRef(__weakPointer); }
	pragma(inline,true)
	final TSharedRef sharedFromThis() const { return TSharedRef(__weakPointer); }


	pragma(inline,true)
	final void initializeFromSharedPointer(ref TSharedRef ptr) const
	{
		__weakPointer = ptr;
	}
private:
	TWeakRef __weakPointer;
}

private:

final class ExternalRefCountData(Alloc,ValueType,bool isShared)
{
	alias Deleter = void function(ref Alloc,ValueType) nothrow;

	this(ValueType ptr, Deleter dele){
		value = ptr;
		deleater = dele;
	}
	Deleter  deleater;
	ValueType value;
	pragma(inline,true)
	int strongDef(){
		static if(isShared)
			return atomicOp!("-=")(_strongref,1);
		else 
			return -- _strongref;
	}
	pragma(inline)
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
	pragma(inline)
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
	
	pragma(inline,true)
	void free(ref Alloc alloc){
		if(deleater && value) 
			deleater(alloc,value);
		deleater = null;
		value = null;
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

