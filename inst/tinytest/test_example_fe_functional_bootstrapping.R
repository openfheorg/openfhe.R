## OPENFHE PYTHON SOURCE: examples/pke/FE-functional-bootstrapping-ckks.py
##
## @openfhe-python: FE-functional-bootstrapping-ckks.py [FULL]
##
## FE (Fourier extension) functional bootstrapping in CKKS: the
## ciphertext is refreshed and a function is evaluated on it in one
## pass, by evaluating the function's Fourier series over the
## bootstrapped message. A small ring runs everywhere; the example's
## parameters (ring dimension 2^16, 2^15 slots) run on request, see
## the end of the file.
library(openfhe.R)

at_home <- tinytest::at_home()

## Fourier coefficients for exp(x) in [-2, 2] of degree 29
coeff_exp_2_double_29 <- complex(
  real = c(3.222093706013e+00, -3.847497325992e+00, 1.613269565467e+00, -7.142688329459e-01,
           3.343375256712e-01, -1.590083748525e-01, 7.444125399842e-02, -3.347789249240e-02,
           1.415639337190e-02, -5.504078824289e-03, 1.912943397918e-03, -5.690043709362e-04,
           1.328669037822e-04, -1.854630094550e-05, -1.453596732859e-06, 1.572743922262e-06,
           -2.838788709181e-07, -7.562004956940e-08, 4.633880680387e-08, -5.869467412101e-10,
           -6.055031566421e-09, 1.190783888161e-09, 7.747582545133e-10, -3.348892690935e-10,
           -9.585399054352e-11, 8.204146390023e-11, 9.573941899682e-12, -2.013818972690e-11,
           1.533040187851e-13, 5.134323521894e-12),
  imaginary = c(0.000000000000e+00, -3.036911315182e+00, 2.561562635536e+00, -1.718044084361e+00,
                1.087677253934e+00, -6.591856314553e-01, 3.797240558554e-01, -2.057416664390e-01,
                1.036151378646e-01, -4.782261609566e-02, 1.985252654576e-02, -7.207032810727e-03,
                2.177453328757e-03, -4.890711403220e-04, 5.053417952833e-05, 1.548627313317e-05,
                -8.312159353832e-06, 8.274522508133e-07, 6.598799631857e-07, -2.528773346321e-07,
                -3.204665662698e-08, 4.385916878681e-08, -3.358504294115e-09, -7.088429287982e-09,
                1.863929871559e-09, 1.136804343802e-09, -5.803840255614e-10, -1.764939479287e-10,
                1.657178907988e-10, 2.323787581630e-11))

## Fourier coefficients for 1 / (1 + exp(-x)) in [-8, 8] of degree 34
coeff_sigmoid_8_double_34 <- complex(
  real = c(2.500000000000e-01, 1.276756478319e-15, -2.711798613355e-15, 2.012279232133e-15,
           -3.874233833051e-17, -5.065392549852e-16, -4.025501720156e-16, 6.661338147751e-16,
           9.549219054383e-17, -4.406197628981e-16, -2.137022113088e-16, 4.614364446098e-16,
           4.897883314203e-19, -4.024558464266e-16, -1.695114860110e-16, 3.903127820948e-16,
           1.909467050622e-16, -9.540979117872e-17, -6.585471100731e-17, 1.040834085586e-16,
           1.641151407480e-16, -6.938893903907e-17, -1.931861246494e-16, 3.035766082959e-16,
           7.532874064103e-17, -1.049507702966e-16, -8.495889538759e-17, 1.587271980519e-16,
           5.298577332100e-17, -3.009745230820e-16, -9.186228167035e-17, 2.055647319033e-16,
           4.123369939761e-16, -3.139849491518e-16, 5.506066522859e-17),
  imaginary = c(0.000000000000e+00, -2.986114677117e-01, -1.305833657358e-03, -6.069910606535e-02,
                -3.496972005070e-03, -1.436915534313e-02, -3.090757902275e-03, -3.011048528323e-03,
                -1.395169741000e-03, -7.358936474771e-04, -4.185575122752e-04, -2.239585471946e-04,
                -1.182545527493e-04, -6.447113701542e-05, -3.521198006050e-05, -1.881494613389e-05,
                -1.006822281208e-05, -5.490602888772e-06, -2.983401096265e-06, -1.590510122180e-06,
                -8.526983863427e-07, -4.673955051855e-07, -2.539297722240e-07, -1.341034123884e-07,
                -7.180768169489e-08, -4.002071006315e-08, -2.179193493192e-08, -1.117364778916e-08,
                -5.959189144748e-09, -3.501207830137e-09, -1.915294608676e-09, -8.879601871852e-10,
                -4.698662414010e-10, -3.309931637583e-10, -1.816820400721e-10))

## Fourier coefficients for the tanh approximation of GELU in [-8, 8]
## of degree 44
coeff_gelu_8_double_44 <- complex(
  real = c(1.970461314322e+00, -1.593875111273e+00, -5.332570094236e-02, -1.570391974449e-01,
           -3.940694771457e-02, -4.716127625363e-02, -2.418730432251e-02, -1.941167643365e-02,
           -1.260556521786e-02, -8.664960605021e-03, -5.704614002479e-03, -3.651093482904e-03,
           -2.270560959509e-03, -1.367226398367e-03, -7.979823621962e-04, -4.528446723700e-04,
           -2.508556888546e-04, -1.363438350097e-04, -7.312414261638e-05, -3.885704183314e-05,
           -2.045210744808e-05, -1.059289000752e-05, -5.323541994507e-06, -2.534606159357e-06,
           -1.095525020071e-06, -3.890401084408e-07, -7.123273537061e-08, 5.044242802621e-08,
           8.120772961289e-08, 7.542928368715e-08, 5.884712616061e-08, 4.212943410103e-08,
           2.870135674255e-08, 1.893829504329e-08, 1.220565836477e-08, 7.712072154498e-09,
           4.784403550098e-09, 2.915358732203e-09, 1.744138401955e-09, 1.034329697769e-09,
           6.098917724102e-10, 3.589237189208e-10, 2.213863333275e-10, 1.478126284614e-10,
           1.014093012815e-10),
  imaginary = c(0.000000000000e+00, -2.423646025475e+00, 1.043627310063e+00, -5.402873054677e-01,
                2.819289867863e-01, -1.391268773786e-01, 6.233923043025e-02, -2.432937320475e-02,
                7.763676253796e-03, -1.754420766855e-03, 1.292565051534e-04, 8.792842531399e-05,
                -3.329062052015e-05, -2.302378982580e-06, 4.854603433774e-06, -5.500080713671e-07,
                -7.491453056646e-07, 2.239517241233e-07, 1.280298946860e-07, -6.935818435338e-08,
                -2.372215028579e-08, 2.148573735963e-08, 4.532466957308e-09, -7.005649868379e-09,
                -8.007947707722e-10, 2.430954434496e-09, 8.161443049159e-11, -8.975149646921e-10,
                3.455961905541e-11, 3.512492108152e-10, -3.699939660207e-11, -1.450199807245e-10,
                2.446543662105e-11, 6.286847323116e-11, -1.443831859627e-11, -2.849185102259e-11,
                8.229923686986e-12, 1.344066297062e-11, -5.307266236734e-12, -6.648169766598e-12,
                3.421664931631e-12, 2.944192267787e-12, -2.779015756058e-12, -1.420742295235e-12,
                4.286355138519e-13))

build_normalized_input <- function(slots) {
  -0.5 + (seq_len(slots) - 1) / slots
}

compute_mean_precision_bits <- function(expected, actual) {
  n <- min(length(expected), length(actual))
  e <- expected[seq_len(n)]
  range_expected <- max(e) - min(e)
  if (range_expected < 1e-15) range_expected <- 1
  mean_error <- mean(abs(e - actual[seq_len(n)]))
  if (mean_error == 0) Inf else -log2(mean_error / range_expected)
}

gelu_tanh <- function(x) {
  0.5 * x * (1 + tanh(sqrt(2 / pi) * (x + 0.044715 * x^3)))
}

## Returns the precision in bits of the three functions, the level of
## the input and the levels of the three outputs.
fe_functional_bootstrapping <- function(ring_dim, num_slots) {
  level_budget <- c(3L, 2L)
  bsgs_dim <- c(0L, 0L)
  ## SPARSE_ENCAPSULATED is the recommended secret key distribution.
  skd <- SecretKeyDist$SPARSE_ENCAPSULATED
  ## get_fefbt_depth() covers the functional bootstrapping itself, for
  ## the longest of the three series; the levels added on top of it are
  ## what is left to compute with on the refreshed ciphertext.
  levels_after_bootstrapping <- 6L
  depth <- max(get_fefbt_depth(level_budget, coeff_exp_2_double_29, skd),
               get_fefbt_depth(level_budget, coeff_sigmoid_8_double_34, skd),
               get_fefbt_depth(level_budget, coeff_gelu_8_double_44, skd)) +
    levels_after_bootstrapping

  cc <- fhe_context("CKKS",
    ckks_data_type = CKKSDataType$COMPLEX,
    secret_key_dist = skd,
    security_level = SecurityLevel$HEStd_NotSet,
    ring_dim = ring_dim,
    num_large_digits = 3L,
    key_switch_technique = KeySwitchTechnique$HYBRID,
    scaling_mod_size = 59L,
    scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
    first_mod_size = 60L,
    batch_size = num_slots,
    multiplicative_depth = depth,
    features = c(Feature$ADVANCEDSHE, Feature$FHE))
  eval_fe_func_bootstrap_setup(cc, level_budget, bsgs_dim, num_slots)

  keys <- key_gen(cc)
  eval_mult_key_gen(cc, keys@secret)
  eval_bootstrap_key_gen(cc, keys@secret, num_slots)

  normalized_input <- build_normalized_input(num_slots)
  plaintext <- make_ckks_packed_plaintext(cc, normalized_input, 1L,
                                          depth - (level_budget[2] + 1L), NULL,
                                          num_slots)
  input <- encrypt(keys@public, plaintext, cc = cc)
  level_before_boot <- get_level(plaintext)

  ## The refresh itself does not depend on the target function, so it
  ## is run once and shared. The powers are precomputed for the longest
  ## series (gelu, degree 44); the shorter ones are evaluated against
  ## those same powers.
  shared_powers <- eval_fe_func_bootstrap_precompute(input, coeff_gelu_8_double_44)

  run_one <- function(radius, coeffs, target) {
    expected <- target(2 * radius * normalized_input)
    output <- eval_fe_func_bootstrap_with_precomp(shared_powers, coeffs)
    decrypted <- decrypt(output, keys@secret, cc = cc)
    set_length(decrypted, length(expected))
    list(precision = compute_mean_precision_bits(expected,
                                                 get_real_packed_value(decrypted)),
         level = get_level(output))
  }
  r_exp <- run_one(2, coeff_exp_2_double_29, exp)
  r_sig <- run_one(8, coeff_sigmoid_8_double_34, function(x) 1 / (1 + exp(-x)))
  r_gelu <- run_one(8, coeff_gelu_8_double_44, gelu_tanh)

  ## The one-step form gives the same function.
  one_step <- eval_fe_func_bootstrap(input, coeff_exp_2_double_29)
  decrypted <- decrypt(one_step, keys@secret, cc = cc)
  set_length(decrypted, num_slots)
  p_one <- compute_mean_precision_bits(exp(4 * normalized_input),
                                       get_real_packed_value(decrypted))

  list(precision = c(exp = r_exp$precision, sigmoid = r_sig$precision,
                     gelu = r_gelu$precision, exp_one_step = p_one),
       level_before = level_before_boot,
       level_after = c(r_exp$level, r_sig$level, r_gelu$level),
       depth = depth)
}

check <- function(res, bits) {
  expect_true(all(res$precision > bits))
  ## The refreshed ciphertexts have levels left to compute with.
  expect_true(all(res$level_after < res$level_before))
  expect_true(all(res$depth - res$level_after >= 1L))
}

check(fe_functional_bootstrapping(2^12, 2^6), 25)
## The example's own size peaks at about 25 GB of memory, so it runs
## only when asked for:
##   OPENFHE_R_LARGE_MEMORY_TESTS=true
if (at_home && identical(Sys.getenv("OPENFHE_R_LARGE_MEMORY_TESTS"), "true")) {
  check(fe_functional_bootstrapping(2^16, 2^15), 25)
}
