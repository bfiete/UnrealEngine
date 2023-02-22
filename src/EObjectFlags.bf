namespace UnrealEngine;

enum EObjectFlags : int32
{
	// Do not add new flags unless they truly belong here. There are alternatives.
	// if you change any the bit of any of the Load flags, then you will need legacy serialization
	NoFlags					= 0x00000000,	///< No flags, used to avoid a cast

	// This first group of flags mostly has to do with what kind of object it is. Other than transient, these are the persistent object flags.
	// The garbage collector also tends to look at these.
	Public					=0x00000001,	///< Object is visible outside its package.
	Standalone				=0x00000002,	///< Keep object around for editing even if unreferenced.
	MarkAsNative			=0x00000004,	///< Object (UField) will be marked as native on construction (DO NOT USE THIS FLAG in HasAnyFlags() etc)
	Transactional			=0x00000008,	///< Object is transactional.
	ClassDefaultObject		=0x00000010,	///< This object is its class's default object
	ArchetypeObject			=0x00000020,	///< This object is a template for another object - treat like a class default object
	Transient				=0x00000040,	///< Don't save object.

	// This group of flags is primarily concerned with garbage collection.
	MarkAsRootSet			=0x00000080,	///< Object will be marked as root set on construction and not be garbage collected, even if unreferenced (DO NOT USE THIS FLAG in HasAnyFlags() etc)
	TagGarbageTemp			=0x00000100,	///< This is a temp user flag for various utilities that need to use the garbage collector. The garbage collector itself does not interpret it.

	// The group of flags tracks the stages of the lifetime of a uobject
	NeedInitialization		=0x00000200,	///< This object has not completed its initialization process. Cleared when ~FObjectInitializer completes
	NeedLoad				=0x00000400,	///< During load, indicates object needs loading.
	KeepForCooker			=0x00000800,	///< Keep this object during garbage collection because it's still being used by the cooker
	NeedPostLoad			=0x00001000,	///< Object needs to be postloaded.
	NeedPostLoadSubobjects	=0x00002000,	///< During load, indicates that the object still needs to instance subobjects and fixup serialized component references
	NewerVersionExists		=0x00004000,	///< Object has been consigned to oblivion due to its owner package being reloaded, and a newer version currently exists
	BeginDestroyed			=0x00008000,	///< BeginDestroy has been called on the object.
	FinishDestroyed			=0x00010000,	///< FinishDestroy has been called on the object.

	// Misc. Flags
	BeingRegenerated		=0x00020000,	///< Flagged on UObjects that are used to create UClasses (e.g. Blueprints) while they are regenerating their UClass on load (See FLinkerLoad::CreateExport()), as well as UClass objects in the midst of being created
	DefaultSubObject		=0x00040000,	///< Flagged on subobjects that are defaults
	WasLoaded				=0x00080000,	///< Flagged on UObjects that were loaded
	TextExportTransient		=0x00100000,	///< Do not export object to text form (e.g. copy/paste). Generally used for sub-objects that can be regenerated from data in their parent object.
	LoadCompleted			=0x00200000,	///< Object has been completely serialized by linkerload at least once. DO NOT USE THIS FLAG, It should be replaced with WasLoaded.
	InheritableComponentTemplate = 0x00400000, ///< Archetype of the object can be in its super class
	DuplicateTransient		=0x00800000,	///< Object should not be included in any type of duplication (copy/paste, binary duplication, etc.)
	StrongRefOnFrame		=0x01000000,	///< References to this object from persistent function frame are handled as strong ones.
	NonPIEDuplicateTransient=0x02000000,	///< Object should not be included for duplication unless it's being duplicated for a PIE session
	Dynamic 				=0x04000000,	///< Field Only. Dynamic field - doesn't get constructed during static initialization, can be constructed multiple times  // @todo: BP2CPP_remove
	WillBeLoaded			=0x08000000,	///< This object was constructed during load and will be loaded shortly
	HasExternalPackage		=0x10000000,	///< This object has an external package assigned and should look it up when getting the outermost package

	// Garbage and PendingKill are mirrored in EInternalObjectFlags because checking the internal flags is much faster for the Garbage Collector
	// while checking the object flags is much faster outside of it where the Object pointer is already available and most likely cached.
	// PendingKill is mirrored in EInternalObjectFlags because checking the internal flags is much faster for the Garbage Collector
	// while checking the object flags is much faster outside of it where the Object pointer is already available and most likely cached.

	PendingKill = 0x20000000,	///< Objects that are pending destruction (invalid for gameplay but valid objects). This flag is mirrored in EInternalObjectFlags as PendingKill for performance
	Garbage = 0x40000000,	///< Garbage from logical point of view and should not be referenced. This flag is mirrored in EInternalObjectFlags as Garbage for performance
	AllocatedInSharedPage	= (.)0x80000000,	///< Allocated from a ref-counted page shared with other UObjects
}