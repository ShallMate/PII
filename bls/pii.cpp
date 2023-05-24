/*
 * fake-spdz-bls-party.cpp
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

#include <assert.h>
#include "piiprotocol.hpp"


int main(int argc, const char** argv)
{
    testrun<Share>(argc, argv);

}