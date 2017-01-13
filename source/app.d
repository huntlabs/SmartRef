import std.stdio;
import std.experimental.allocator;
import std.experimental.allocator.gc_allocator;
import std.exception;

import smartref;

void smartfreeSharedInt(ref typeof(SmartGCAllocator.instance) alloc, int * d)nothrow {
	collectException({
			writeln("free the int");
			alloc.dispose(d);
		}());
}

void freeSharedInt(ref typeof(GCAllocator.instance) alloc, int * d)nothrow {
	collectException({
			writeln("free the int");
			alloc.dispose(d);
		}());
}

void main()
{
	{
		//auto malloc = 
		auto a = GCAllocator.instance.makeISharedRefWithDeleter!(int)(&freeSharedInt,10);
		assert(*a == 10);
		auto b = GCAllocator.instance.makeISharedRef!int(100);
		assert(*b == 100);
		auto a1 = makeSharedRefWithDeleter!(int)(&smartfreeSharedInt,10);
		assert(*a1 == 10);
		auto b1 = makeSharedRef!int(100);
		assert(*b1 == 100);

	}
	writeln("Edit source/app.d to start your project.");


	auto a = makeIScopedRefWithDeleter!(int)(GCAllocator.instance,&freeSharedInt);
	auto a1 = makeScopedRefWithDeleter!(int)(&smartfreeSharedInt);
}
