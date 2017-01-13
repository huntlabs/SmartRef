import std.stdio;
import std.experimental.allocator;
import std.experimental.allocator.gc_allocator;
import std.exception;

import smartref.sharedref;
import smartref.scopedref;

void freeSharedInt(ref typeof(GCAllocator.instance) alloc, int * d)nothrow {
	collectException({
			writeln("free the int");
			alloc.dispose(d);
		}());
}

void main()
{

	alias SharedInt = SharedRef!(typeof(GCAllocator.instance),int);
	{
		SharedInt a = SharedInt(new int(10), &freeSharedInt);
		assert(*a == 10);
	}
	writeln("Edit source/app.d to start your project.");
	alias ScopedInt = ScopedRef!(typeof(GCAllocator.instance),int);

	ScopedInt a = ScopedInt(new int(10), &freeSharedInt);
}
