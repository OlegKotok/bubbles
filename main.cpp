#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <box2dplugin.h>


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    Box2DPlugin plugin;
    plugin.registerTypes("Box2DStatic");


    engine.load(url);

    return app.exec();
}
