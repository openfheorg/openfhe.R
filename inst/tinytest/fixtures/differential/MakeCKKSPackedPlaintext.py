#!/usr/bin/env python3
# OPENFHE PYTHON SOURCE: openfhe/openfhe-python/src/lib/bindings.cpp (MakeCKKSPackedPlaintext)
# R-SPECIFIC: Signal 2 Python companion to MakeCKKSPackedPlaintext.R
#
# Runs the four optional-argument perturbations against the same C++
# OpenFHE library that the R package links against (via
# temp/openfhe-python-venv/, which was built against
# temp/openfhe-rlibomp/). Emits a JSON dict to stdout that the R-side
# harness reads via system2(stdout = TRUE).
#
# Per harness.md §3.4, the Python side runs end-to-end while
# the R side initially reported `probe_not_available` for every
# probe (see the .R companion). The initial gate was "the framework
# runs end-to-end without crashing"; once the R-side Plaintext
# metadata accessors landed, a real R↔Python three-way differential
# became possible.

from __future__ import annotations

import json
import sys
import traceback


def main() -> int:
    try:
        from openfhe import (CCParamsCKKSRNS, GenCryptoContext,
                             PKESchemeFeature, ScalingTechnique)
    except ImportError as exc:
        json.dump({
            "method": "MakeCKKSPackedPlaintext",
            "error": "openfhe import failed: {}".format(exc),
            "perturbations": {},
        }, sys.stdout)
        return 2

    try:
        # FIXEDMANUAL is mandatory for this fixture: under the default
        # FLEXIBLEAUTO, the auto-rescale logic silently overrides the
        # user-supplied noiseScaleDeg every call, so the perturbation
        # degenerates to a constant. FIXEDMANUAL preserves the
        # user-supplied value verbatim; see
        # discovery D011 in notes/discoveries/.
        params = CCParamsCKKSRNS()
        params.SetMultiplicativeDepth(4)
        params.SetScalingModSize(50)
        params.SetBatchSize(8)
        params.SetScalingTechnique(ScalingTechnique.FIXEDMANUAL)
        cc = GenCryptoContext(params)
        cc.Enable(PKESchemeFeature.PKE)
        cc.Enable(PKESchemeFeature.LEVELEDSHE)
        values = [1.0, 2.0, 3.0, 4.0]

        # ---- noiseScaleDeg ----
        try:
            pt_default = cc.MakeCKKSPackedPlaintext(values)
            pt_perturbed = cc.MakeCKKSPackedPlaintext(values, noiseScaleDeg=2)
            noise_default = pt_default.GetNoiseScaleDeg()
            noise_perturbed = pt_perturbed.GetNoiseScaleDeg()
            noise_block = {
                "default": noise_default,
                "perturbed": noise_perturbed,
                "direction": "increases",
                "matches_prediction": noise_perturbed > noise_default,
            }
        except Exception as exc:
            noise_block = {"error": str(exc), "direction": "increases"}

        # ---- level ----
        try:
            pt_level_default = cc.MakeCKKSPackedPlaintext(values)
            pt_level_perturbed = cc.MakeCKKSPackedPlaintext(values, level=1)
            level_default = pt_level_default.GetLevel()
            level_perturbed = pt_level_perturbed.GetLevel()
            level_block = {
                "default": level_default,
                "perturbed": level_perturbed,
                "direction": "increases",
                "matches_prediction": level_perturbed >= level_default,
            }
        except Exception as exc:
            level_block = {"error": str(exc), "direction": "increases"}

        # ---- params ----
        # openfhe.CryptoContext does not bind the bulk
        # GetCryptoParameters() accessor — Python exposes the
        # per-attribute getters instead (GetBatchSize,
        # GetMultiplicativeDepth, GetScalingTechnique,
        # GetRingDimension, GetCyclotomicOrder, etc., 24 in total).
        # Calling cc.GetCryptoParameters() raises AttributeError.
        # The params perturbation is therefore deferred until
        # the harness can either compose a params object from the
        # per-attribute getters or rely on a bulk-getter binding
        # added by openfhe-python upstream. This is not an upstream
        # defect; it is a deliberate Python ergonomic choice.
        params_block = {
            "default": "probe_not_available",
            "perturbed": "probe_not_available",
            "direction": "changes",
            "matches_prediction": None,
            "note": ("params pointer probe deferred — "
                     "openfhe.CryptoContext exposes per-attribute "
                     "getters instead of GetCryptoParameters()"),
        }

        # ---- slots ----
        try:
            pt_slots_default = cc.MakeCKKSPackedPlaintext(values)
            pt_slots_perturbed = cc.MakeCKKSPackedPlaintext(values, slots=4)
            slots_default = pt_slots_default.GetSlots()
            slots_perturbed = pt_slots_perturbed.GetSlots()
            slots_block = {
                "default": slots_default,
                "perturbed": slots_perturbed,
                "direction": "changes",
                "matches_prediction": slots_default != slots_perturbed,
            }
        except Exception as exc:
            slots_block = {"error": str(exc), "direction": "changes"}

        result = {
            "method": "MakeCKKSPackedPlaintext",
            "stack": "python",
            "mode": "live_at_9100_0",
            "perturbations": {
                "noiseScaleDeg": noise_block,
                "level": level_block,
                "params": params_block,
                "slots": slots_block,
            },
        }
        json.dump(result, sys.stdout)
        return 0
    except Exception:
        json.dump({
            "method": "MakeCKKSPackedPlaintext",
            "error": "unexpected exception",
            "traceback": traceback.format_exc(),
            "perturbations": {},
        }, sys.stdout)
        return 1


if __name__ == "__main__":
    sys.exit(main())
