/*
 * fake-spdz-ibs-party.cpp
 *
 */

#define NO_MIXED_CIRCUITS

#define NO_SECURITY_CHECK

#include "GC/TinierSecret.h"
#include "GC/TinyMC.h"
#include "GC/VectorInput.h"

#include "Protocols/Share.hpp"
#include "Protocols/MAC_Check.hpp"
#include "GC/Secret.hpp"
#include "GC/TinierSharePrep.hpp"
#include "ot-ibs-party.hpp"
#include "P256Element.h"
#include "ibsElement.h"
#include "Tools/Bundle.h"
#include "Tools/random.h"
using namespace std;

#include <assert.h>

extern "C" {
#include <relic/relic_core.h>
#include <relic/relic_bn.h>
#include <relic/relic_pc.h>
#include <relic/relic_cp.h>
}


inline G1Element::Scalar sha256(const unsigned char* message, size_t length)
{
    G1Element::Scalar res;
    assert(res.size() == crypto_hash_sha256_BYTES);
    crypto_hash_sha256((unsigned char *)res.get_ptr(), message, length);
    res.zero_overhang();
    return res;
}


int main()
{
    unsigned char* id = (unsigned char*)"123";
    G1Element::Scalar hid = sha256(id,3);
    G1Element G1;
    auto s = SeededPRNG().get<P256Element::Scalar>();
    G1Element::Scalar skidscalar = s+hid;
    G1Element skid = (skidscalar.invert())*G1;

}
