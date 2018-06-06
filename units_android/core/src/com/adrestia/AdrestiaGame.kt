package com.adrestia

import com.badlogic.gdx.ApplicationAdapter
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.glutils.ShapeRenderer

class AdrestiaGame : ApplicationAdapter() {
    private var camera: OrthographicCamera? = null
    private var batch: SpriteBatch? = null
    private var renderer: ShapeRenderer? = null

    override fun create() {
        batch = SpriteBatch()
        camera = OrthographicCamera()
        renderer = ShapeRenderer()
    }

    override fun render() {
        Gdx.gl.glClearColor(1f, 0f, 0f, 1f)
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)

        val r = renderer
        if (r != null) {
            r.begin(ShapeRenderer.ShapeType.Filled)
            r.setColor(0f, 0f, 0.8f, 0f)
            r.circle(Gdx.graphics.width / 2f, Gdx.graphics.height / 2f, 100f)
            r.end()
        }
    }

    override fun dispose() {
        batch!!.dispose()
    }
}
