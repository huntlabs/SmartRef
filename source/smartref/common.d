module smartref.common;

import std.experimental.allocator;
import std.experimental.allocator.mallocator;
import std.experimental.allocator.building_blocks.free_list;

shared static this(){
	_smartRefAllocator = allocatorObject(Mallocator.instance);
}

@property IAllocator smartRefAllocator()
{
	return _smartRefAllocator;
}


@property void smartRefAllocator(IAllocator a)
{
	assert(a);
	_smartRefAllocator = a;
}

//
//class CAllocatorImpl(Allocator, Flag!"indirect" indirect = No.indirect)
//	: IAllocator
//{
//	import std.traits : hasMember;
//	
//	/**
//    The implementation is available as a public member.
//    */
//	static if (indirect)
//	{
//		private Allocator* pimpl;
//		ref Allocator impl()
//		{
//			return *pimpl;
//		}
//		this(Allocator* pa)
//		{
//			pimpl = pa;
//		}
//	}
//	else
//	{
//		static if (stateSize!Allocator) Allocator impl;
//		else alias impl = Allocator.instance;
//	}
//	
//	/// Returns $(D impl.alignment).
//	override @property uint alignment()
//	{
//		return impl.alignment;
//	}
//	
//	/**
//    Returns $(D impl.goodAllocSize(s)).
//    */
//	override size_t goodAllocSize(size_t s)
//	{
//		return impl.goodAllocSize(s);
//	}
//	
//	/**
//    Returns $(D impl.allocate(s)).
//    */
//	override void[] allocate(size_t s, TypeInfo ti = null)
//	{
//		return impl.allocate(s);
//	}
//	
//	/**
//    If $(D impl.alignedAllocate) exists, calls it and returns the result.
//    Otherwise, always returns `null`.
//    */
//	override void[] alignedAllocate(size_t s, uint a)
//	{
//		static if (hasMember!(Allocator, "alignedAllocate"))
//			return impl.alignedAllocate(s, a);
//		else
//			return null;
//	}
//	
//	/**
//    If `Allocator` implements `owns`, forwards to it. Otherwise, returns
//    `Ternary.unknown`.
//    */
//	override Ternary owns(void[] b)
//	{
//		static if (hasMember!(Allocator, "owns")) return impl.owns(b);
//		else return Ternary.unknown;
//	}
//	
//	/// Returns $(D impl.expand(b, s)) if defined, $(D false) otherwise.
//	override bool expand(ref void[] b, size_t s)
//	{
//		static if (hasMember!(Allocator, "expand"))
//			return impl.expand(b, s);
//		else
//			return s == 0;
//	}
//	
//	/// Returns $(D impl.reallocate(b, s)).
//	override bool reallocate(ref void[] b, size_t s)
//	{
//		return impl.reallocate(b, s);
//	}
//	
//	/// Forwards to $(D impl.alignedReallocate).
//	bool alignedReallocate(ref void[] b, size_t s, uint a)
//	{
//		static if (!hasMember!(Allocator, "alignedAllocate"))
//		{
//			return false;
//		}
//		else
//		{
//			return impl.alignedReallocate(b, s, a);
//		}
//	}
//	
//	// Undocumented for now
//	Ternary resolveInternalPointer(void* p, ref void[] result)
//	{
//		static if (hasMember!(Allocator, "resolveInternalPointer"))
//		{
//			result = impl.resolveInternalPointer(p);
//			return Ternary(result.ptr !is null);
//		}
//		else
//		{
//			return Ternary.unknown;
//		}
//	}
//	
//	/**
//    If $(D impl.deallocate) is not defined, returns $(D Ternary.unknown). If
//    $(D impl.deallocate) returns $(D void) (the common case), calls it and
//    returns $(D Ternary.yes). If $(D impl.deallocate) returns $(D bool), calls
//    it and returns $(D Ternary.yes) for $(D true), $(D Ternary.no) for $(D
//    false).
//    */
//	override bool deallocate(void[] b)
//	{
//		static if (hasMember!(Allocator, "deallocate"))
//		{
//			return impl.deallocate(b);
//		}
//		else
//		{
//			return false;
//		}
//	}
//	
//	/**
//    Calls $(D impl.deallocateAll()) and returns $(D Ternary.yes) if defined,
//    otherwise returns $(D Ternary.unknown).
//    */
//	override bool deallocateAll()
//	{
//		static if (hasMember!(Allocator, "deallocateAll"))
//		{
//			return impl.deallocateAll();
//		}
//		else
//		{
//			return false;
//		}
//	}
//	
//	/**
//    Forwards to $(D impl.empty()) if defined, otherwise returns
//    $(D Ternary.unknown).
//    */
//	override Ternary empty()
//	{
//		static if (hasMember!(Allocator, "empty"))
//		{
//			return Ternary(impl.empty);
//		}
//		else
//		{
//			return Ternary.unknown;
//		}
//	}
//	
//	/**
//    Returns $(D impl.allocateAll()) if present, $(D null) otherwise.
//    */
//	override void[] allocateAll()
//	{
//		static if (hasMember!(Allocator, "allocateAll"))
//		{
//			return impl.allocateAll();
//		}
//		else
//		{
//			return null;
//		}
//	}
//}

private:
__gshared IAllocator _smartRefAllocator;