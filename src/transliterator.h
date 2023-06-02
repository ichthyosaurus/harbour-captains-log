#ifndef TRANSLITERATOR_H
#define TRANSLITERATOR_H

#include <QObject>
#include <unicode/translit.h>

class Transliterator : public QObject
{
    Q_OBJECT

public:
    explicit Transliterator(QObject *parent = nullptr);
    virtual ~Transliterator();

    Q_INVOKABLE QString normalize(const QString& source);

private:
    icu::Transliterator* m_transliterator;
};

#endif // TRANSLITERATOR_H
