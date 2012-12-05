if __name__ == "__main__":
    # To allow aptana to receive errors, set use_debugger=False
    #app = create_app(config="config.yaml")
    import flaskr
    app = flaskr.app.run()

    if app.debug: use_debugger = True
    try:
        # Disable Flask's debugger if external debugger is requested
        use_debugger = not(app.config.get('DEBUG_WITH_APTANA'))
    except:
        pass
    app.run(use_debugger=use_debugger, debug=app.debug,
            use_reloader=use_debugger, host='0.0.0.0')
