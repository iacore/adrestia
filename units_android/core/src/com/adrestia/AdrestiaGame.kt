package com.adrestia

import com.badlogic.gdx.ApplicationAdapter
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.glutils.ShapeRenderer
import com.badlogic.gdx.scenes.scene2d.Stage
import com.badlogic.gdx.scenes.scene2d.ui.Skin
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.badlogic.gdx.scenes.scene2d.ui.TextButton
import com.badlogic.gdx.scenes.scene2d.utils.ChangeListener
import com.badlogic.gdx.utils.viewport.FitViewport

class AdrestiaGame : ApplicationAdapter() {
    private var skin: Skin? = null
    private var camera: OrthographicCamera? = null
    private var batch: SpriteBatch? = null
    private var renderer: ShapeRenderer? = null
    private var stage: Stage? = null

    override fun create() {
        skin = Skin(Gdx.files.internal("ui_skin/skin/uiskin.json"))
        batch = SpriteBatch()
        camera = OrthographicCamera()
        renderer = ShapeRenderer()

        stage = Stage(FitViewport(400f, 600f))
        Gdx.input.setInputProcessor(stage)

        val table = Table()
        table.setFillParent(true)
        stage!!.addActor(table)

        val button = TextButton("click me", skin)
        table.add(button)

        var bitcoins = 0

        button.addListener {
            bitcoins += 1
            button.setText("$bitcoins bitcoins mined")
            true
        }
    }

    override fun render() {
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1f)
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)

        val r = renderer
        if (r != null) {
            r.begin(ShapeRenderer.ShapeType.Filled)
            r.setColor(0f, 0f, 0.8f, 0f)
            r.circle(Gdx.graphics.width / 2f, Gdx.graphics.height / 2f, 100f)
            r.end()
        }
        stage!!.act(1 / 30f)
        stage!!.draw()
    }

    override fun resize(width: Int, height: Int) {
        stage!!.getViewport().update(width, height, true)
    }

    override fun dispose() {
        stage!!.dispose()
        batch!!.dispose()
        skin!!.dispose()
    }

    // Other methods: resize, pause, resume, dispose
}
