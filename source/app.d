import std.stdio;
import std.experimental.allocator;
import std.experimental.allocator.gc_allocator;
import std.exception;

import smartref;

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
		auto a = GCAllocator.instance.makeSharedRefWithDeleter!(int)(&freeSharedInt,10);
		assert(*a == 10);
		auto b = GCAllocator.instance.makeSharedRef!int();
		*b = 100;

	}
	writeln("Edit source/app.d to start your project.");


	auto a = makeScopedRefWithDeleter!(int)(GCAllocator.instance,&freeSharedInt);
}
