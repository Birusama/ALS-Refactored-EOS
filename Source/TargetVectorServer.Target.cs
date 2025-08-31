// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class TargetVectorServerTarget : TargetRules
{
    public TargetVectorServerTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Server;
        DefaultBuildSettings = BuildSettingsVersion.Latest;
		bOverrideBuildEnvironment = true;
		bWithPushModel = true;
        ExtraModuleNames.Add("TargetVector");
    }
}