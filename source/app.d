import std.stdio;
import smartref.sharedref;
import std.experimental.allocator;
import std.experimental.allocator.gc_allocator;
import std.exception;

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
}
