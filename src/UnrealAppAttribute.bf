using System;

namespace UnrealEngine;

[AttributeUsage(.Class, .DisallowAllowMultiple, AlwaysIncludeUser=.AssumeInstantiated, ReflectUser=.DefaultConstructor)]
struct UnrealAppAttribute : Attribute
{
}
