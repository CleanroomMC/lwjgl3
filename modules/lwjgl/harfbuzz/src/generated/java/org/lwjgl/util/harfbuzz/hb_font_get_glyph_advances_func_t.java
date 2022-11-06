/*
 * Copyright LWJGL. All rights reserved.
 * License terms: https://www.lwjgl.org/license
 * MACHINE GENERATED FILE, DO NOT EDIT
 */
package org.lwjgl.util.harfbuzz;

import javax.annotation.*;

import org.lwjgl.system.*;

import static org.lwjgl.system.MemoryUtil.*;

/**
 * <h3>Type</h3>
 * 
 * <pre><code>
 * void (*{@link #invoke}) (
 *     hb_font_t *font,
 *     void *font_data,
 *     unsigned int count,
 *     hb_codepoint_t const *first_glyph,
 *     unsigned int glyph_stride,
 *     hb_position_t *first_advance,
 *     unsigned int advance_stride,
 *     void *user_data
 * )</code></pre>
 */
public abstract class hb_font_get_glyph_advances_func_t extends Callback implements hb_font_get_glyph_advances_func_tI {

    /**
     * Creates a {@code hb_font_get_glyph_advances_func_t} instance from the specified function pointer.
     *
     * @return the new {@code hb_font_get_glyph_advances_func_t}
     */
    public static hb_font_get_glyph_advances_func_t create(long functionPointer) {
        hb_font_get_glyph_advances_func_tI instance = Callback.get(functionPointer);
        return instance instanceof hb_font_get_glyph_advances_func_t
            ? (hb_font_get_glyph_advances_func_t)instance
            : new Container(functionPointer, instance);
    }

    /** Like {@link #create(long) create}, but returns {@code null} if {@code functionPointer} is {@code NULL}. */
    @Nullable
    public static hb_font_get_glyph_advances_func_t createSafe(long functionPointer) {
        return functionPointer == NULL ? null : create(functionPointer);
    }

    /** Creates a {@code hb_font_get_glyph_advances_func_t} instance that delegates to the specified {@code hb_font_get_glyph_advances_func_tI} instance. */
    public static hb_font_get_glyph_advances_func_t create(hb_font_get_glyph_advances_func_tI instance) {
        return instance instanceof hb_font_get_glyph_advances_func_t
            ? (hb_font_get_glyph_advances_func_t)instance
            : new Container(instance.address(), instance);
    }

    protected hb_font_get_glyph_advances_func_t() {
        super(CIF);
    }

    hb_font_get_glyph_advances_func_t(long functionPointer) {
        super(functionPointer);
    }

    private static final class Container extends hb_font_get_glyph_advances_func_t {

        private final hb_font_get_glyph_advances_func_tI delegate;

        Container(long functionPointer, hb_font_get_glyph_advances_func_tI delegate) {
            super(functionPointer);
            this.delegate = delegate;
        }

        @Override
        public void invoke(long font, long font_data, int count, long first_glyph, int glyph_stride, long first_advance, int advance_stride, long user_data) {
            delegate.invoke(font, font_data, count, first_glyph, glyph_stride, first_advance, advance_stride, user_data);
        }

    }

}