#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QDebug>
#include <QtQml>

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    
    // Box2D plugin will be automatically registered via CMake qt_add_qml_module
    
    // In Qt6, with qt_add_qml_module, QML files are available at /qt/qml/ prefix
    const QUrl url(u"qrc:/qt/qml/Bubbles/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl){
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    });
    engine.load(url);
    
    return app.exec();
}
