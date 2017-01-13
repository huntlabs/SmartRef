module smartref.common;

import std.experimental.allocator;
import std.experimental.allocator.mallocator;
import std.experimental.allocator.building_blocks.free_list;

shared static this(){
	auto f1 = SharedFreeList!(typeof(Mallocator.instance),8)();
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

private:
__gshared IAllocator _smartRefAllocator;