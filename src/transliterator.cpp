#include "transliterator.h"

#include <unicode/unistr.h>
#include <unicode/utrans.h>
#include <unicode/utypes.h>
#include <QDebug>


Transliterator::Transliterator(QObject *parent) : QObject(parent)
{
    UErrorCode status = U_ZERO_ERROR;
    m_transliterator = icu::Transliterator::createInstance(
        "NFKD; Any-Latin; Latin-ASCII; Lower; [:Nonspacing Mark:] Remove;",
        UTransDirection::UTRANS_FORWARD, status);
    qDebug() << "transliterator created:" << status;
}

Transliterator::~Transliterator()
{
    delete m_transliterator;
}

QString Transliterator::normalize(const QString& source)
{
    auto str = icu::UnicodeString(source.toStdString().c_str());
    m_transliterator->transliterate(str);
    std::string converted;
    str.toUTF8String(converted);

    return QString{converted.c_str()};
}
