/*
 * Copyright LWJGL. All rights reserved.
 * License terms: https://www.lwjgl.org/license
 */
module org.lwjgl.ovr {
    requires transitive org.lwjgl;

    requires static transitive org.lwjgl.opengl;
    requires static transitive org.lwjgl.vulkan;

    exports org.lwjgl.ovr;
}