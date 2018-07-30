/*
 * Copyright LWJGL. All rights reserved.
 * License terms: https://www.lwjgl.org/license
 * MACHINE GENERATED FILE, DO NOT EDIT
 */
package org.lwjgl.openvr;

import javax.annotation.*;

import java.nio.*;

import org.lwjgl.*;
import org.lwjgl.system.*;

import static org.lwjgl.system.Checks.*;
import static org.lwjgl.system.MemoryUtil.*;
import static org.lwjgl.system.MemoryStack.*;

/**
 * <h3>Layout</h3>
 * 
 * <pre><code>
 * struct HmdQuad_t {
 *     {@link HmdVector3 HmdVector3_t} vCorners[4];
 * }</code></pre>
 */
@NativeType("struct HmdQuad_t")
public class HmdQuad extends Struct implements NativeResource {

    /** The struct size in bytes. */
    public static final int SIZEOF;

    /** The struct alignment in bytes. */
    public static final int ALIGNOF;

    /** The struct member offsets. */
    public static final int
        VCORNERS;

    static {
        Layout layout = __struct(
            __array(HmdVector3.SIZEOF, HmdVector3.ALIGNOF, 4)
        );

        SIZEOF = layout.getSize();
        ALIGNOF = layout.getAlignment();

        VCORNERS = layout.offsetof(0);
    }

    HmdQuad(long address, @Nullable ByteBuffer container) {
        super(address, container);
    }

    /**
     * Creates a {@link HmdQuad} instance at the current position of the specified {@link ByteBuffer} container. Changes to the buffer's content will be
     * visible to the struct instance and vice versa.
     *
     * <p>The created instance holds a strong reference to the container object.</p>
     */
    public HmdQuad(ByteBuffer container) {
        this(memAddress(container), __checkContainer(container, SIZEOF));
    }

    @Override
    public int sizeof() { return SIZEOF; }

    /** Returns a {@link HmdVector3}.Buffer view of the {@code vCorners} field. */
    @NativeType("HmdVector3_t[4]")
    public HmdVector3.Buffer vCorners() { return nvCorners(address()); }
    /** Returns a {@link HmdVector3} view of the struct at the specified index of the {@code vCorners} field. */
    @NativeType("HmdVector3_t")
    public HmdVector3 vCorners(int index) { return nvCorners(address(), index); }

    /** Copies the specified {@link HmdVector3.Buffer} to the {@code vCorners} field. */
    public HmdQuad vCorners(@NativeType("HmdVector3_t[4]") HmdVector3.Buffer value) { nvCorners(address(), value); return this; }
    /** Copies the specified {@link HmdVector3} at the specified index of the {@code vCorners} field. */
    public HmdQuad vCorners(int index, @NativeType("HmdVector3_t") HmdVector3 value) { nvCorners(address(), index, value); return this; }

    /**
     * Copies the specified struct data to this struct.
     *
     * @param src the source struct
     *
     * @return this struct
     */
    public HmdQuad set(HmdQuad src) {
        memCopy(src.address(), address(), SIZEOF);
        return this;
    }

    // -----------------------------------

    /** Returns a new {@link HmdQuad} instance allocated with {@link MemoryUtil#memAlloc memAlloc}. The instance must be explicitly freed. */
    public static HmdQuad malloc() {
        return create(nmemAllocChecked(SIZEOF));
    }

    /** Returns a new {@link HmdQuad} instance allocated with {@link MemoryUtil#memCalloc memCalloc}. The instance must be explicitly freed. */
    public static HmdQuad calloc() {
        return create(nmemCallocChecked(1, SIZEOF));
    }

    /** Returns a new {@link HmdQuad} instance allocated with {@link BufferUtils}. */
    public static HmdQuad create() {
        return new HmdQuad(BufferUtils.createByteBuffer(SIZEOF));
    }

    /** Returns a new {@link HmdQuad} instance for the specified memory address. */
    public static HmdQuad create(long address) {
        return new HmdQuad(address, null);
    }

    /** Like {@link #create(long) create}, but returns {@code null} if {@code address} is {@code NULL}. */
    @Nullable
    public static HmdQuad createSafe(long address) {
        return address == NULL ? null : create(address);
    }

    /**
     * Returns a new {@link HmdQuad.Buffer} instance allocated with {@link MemoryUtil#memAlloc memAlloc}. The instance must be explicitly freed.
     *
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer malloc(int capacity) {
        return create(__malloc(capacity, SIZEOF), capacity);
    }

    /**
     * Returns a new {@link HmdQuad.Buffer} instance allocated with {@link MemoryUtil#memCalloc memCalloc}. The instance must be explicitly freed.
     *
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer calloc(int capacity) {
        return create(nmemCallocChecked(capacity, SIZEOF), capacity);
    }

    /**
     * Returns a new {@link HmdQuad.Buffer} instance allocated with {@link BufferUtils}.
     *
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer create(int capacity) {
        return new Buffer(__create(capacity, SIZEOF));
    }

    /**
     * Create a {@link HmdQuad.Buffer} instance at the specified memory.
     *
     * @param address  the memory address
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer create(long address, int capacity) {
        return new Buffer(address, capacity);
    }

    /** Like {@link #create(long, int) create}, but returns {@code null} if {@code address} is {@code NULL}. */
    @Nullable
    public static HmdQuad.Buffer createSafe(long address, int capacity) {
        return address == NULL ? null : create(address, capacity);
    }

    // -----------------------------------

    /** Returns a new {@link HmdQuad} instance allocated on the thread-local {@link MemoryStack}. */
    public static HmdQuad mallocStack() {
        return mallocStack(stackGet());
    }

    /** Returns a new {@link HmdQuad} instance allocated on the thread-local {@link MemoryStack} and initializes all its bits to zero. */
    public static HmdQuad callocStack() {
        return callocStack(stackGet());
    }

    /**
     * Returns a new {@link HmdQuad} instance allocated on the specified {@link MemoryStack}.
     *
     * @param stack the stack from which to allocate
     */
    public static HmdQuad mallocStack(MemoryStack stack) {
        return create(stack.nmalloc(ALIGNOF, SIZEOF));
    }

    /**
     * Returns a new {@link HmdQuad} instance allocated on the specified {@link MemoryStack} and initializes all its bits to zero.
     *
     * @param stack the stack from which to allocate
     */
    public static HmdQuad callocStack(MemoryStack stack) {
        return create(stack.ncalloc(ALIGNOF, 1, SIZEOF));
    }

    /**
     * Returns a new {@link HmdQuad.Buffer} instance allocated on the thread-local {@link MemoryStack}.
     *
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer mallocStack(int capacity) {
        return mallocStack(capacity, stackGet());
    }

    /**
     * Returns a new {@link HmdQuad.Buffer} instance allocated on the thread-local {@link MemoryStack} and initializes all its bits to zero.
     *
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer callocStack(int capacity) {
        return callocStack(capacity, stackGet());
    }

    /**
     * Returns a new {@link HmdQuad.Buffer} instance allocated on the specified {@link MemoryStack}.
     *
     * @param stack the stack from which to allocate
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer mallocStack(int capacity, MemoryStack stack) {
        return create(stack.nmalloc(ALIGNOF, capacity * SIZEOF), capacity);
    }

    /**
     * Returns a new {@link HmdQuad.Buffer} instance allocated on the specified {@link MemoryStack} and initializes all its bits to zero.
     *
     * @param stack the stack from which to allocate
     * @param capacity the buffer capacity
     */
    public static HmdQuad.Buffer callocStack(int capacity, MemoryStack stack) {
        return create(stack.ncalloc(ALIGNOF, capacity, SIZEOF), capacity);
    }

    // -----------------------------------

    /** Unsafe version of {@link #vCorners}. */
    public static HmdVector3.Buffer nvCorners(long struct) { return HmdVector3.create(struct + HmdQuad.VCORNERS, 4); }
    /** Unsafe version of {@link #vCorners(int) vCorners}. */
    public static HmdVector3 nvCorners(long struct, int index) {
        return HmdVector3.create(struct + HmdQuad.VCORNERS + check(index, 4) * HmdVector3.SIZEOF);
    }

    /** Unsafe version of {@link #vCorners(HmdVector3.Buffer) vCorners}. */
    public static void nvCorners(long struct, HmdVector3.Buffer value) {
        if (CHECKS) { checkGT(value, 4); }
        memCopy(value.address(), struct + HmdQuad.VCORNERS, value.remaining() * HmdVector3.SIZEOF);
    }
    /** Unsafe version of {@link #vCorners(int, HmdVector3) vCorners}. */
    public static void nvCorners(long struct, int index, HmdVector3 value) {
        memCopy(value.address(), struct + HmdQuad.VCORNERS + check(index, 4) * HmdVector3.SIZEOF, HmdVector3.SIZEOF);
    }

    // -----------------------------------

    /** An array of {@link HmdQuad} structs. */
    public static class Buffer extends StructBuffer<HmdQuad, Buffer> implements NativeResource {

        /**
         * Creates a new {@link HmdQuad.Buffer} instance backed by the specified container.
         *
         * Changes to the container's content will be visible to the struct buffer instance and vice versa. The two buffers' position, limit, and mark values
         * will be independent. The new buffer's position will be zero, its capacity and its limit will be the number of bytes remaining in this buffer divided
         * by {@link HmdQuad#SIZEOF}, and its mark will be undefined.
         *
         * <p>The created buffer instance holds a strong reference to the container object.</p>
         */
        public Buffer(ByteBuffer container) {
            super(container, container.remaining() / SIZEOF);
        }

        public Buffer(long address, int cap) {
            super(address, null, -1, 0, cap, cap);
        }

        Buffer(long address, @Nullable ByteBuffer container, int mark, int pos, int lim, int cap) {
            super(address, container, mark, pos, lim, cap);
        }

        @Override
        protected Buffer self() {
            return this;
        }

        @Override
        protected Buffer newBufferInstance(long address, @Nullable ByteBuffer container, int mark, int pos, int lim, int cap) {
            return new Buffer(address, container, mark, pos, lim, cap);
        }

        @Override
        protected HmdQuad newInstance(long address) {
            return new HmdQuad(address, container);
        }

        @Override
        public int sizeof() {
            return SIZEOF;
        }

        /** Returns a {@link HmdVector3}.Buffer view of the {@code vCorners} field. */
        @NativeType("HmdVector3_t[4]")
        public HmdVector3.Buffer vCorners() { return HmdQuad.nvCorners(address()); }
        /** Returns a {@link HmdVector3} view of the struct at the specified index of the {@code vCorners} field. */
        @NativeType("HmdVector3_t")
        public HmdVector3 vCorners(int index) { return HmdQuad.nvCorners(address(), index); }

        /** Copies the specified {@link HmdVector3.Buffer} to the {@code vCorners} field. */
        public HmdQuad.Buffer vCorners(@NativeType("HmdVector3_t[4]") HmdVector3.Buffer value) { HmdQuad.nvCorners(address(), value); return this; }
        /** Copies the specified {@link HmdVector3} at the specified index of the {@code vCorners} field. */
        public HmdQuad.Buffer vCorners(int index, @NativeType("HmdVector3_t") HmdVector3 value) { HmdQuad.nvCorners(address(), index, value); return this; }

    }

}