test_that("closest throws errors", {
    expect_error(closest(1, c(0, -1, 3)), "sorted non-decreasingly")
    expect_error(closest(3:1, 1), "sorted non-decreasingly")
    expect_error(closest(), "missing, with no default")
    expect_error(closest(1:3, 1:3, tolerance = -1), "larger or equal zero")
    expect_error(closest(1:3, 1:3, tolerance = 1:(-1)), "larger or equal zero")
    expect_error(closest(1:3, 1:3, tolerance = 1:2), "length 1")
    expect_error(closest(1:3, 1:3, ppm = -1), "larger or equal zero")
    expect_warning(closest(1:3, 1:3, ppm = 1:2), "not a multiple of")
    expect_error(closest(1:3, 1.3, tolerance = TRUE), "numeric")
    expect_error(closest(1:3, 1:3, nomatch = TRUE), "be a 'numeric'")
    expect_error(closest(1, 1, nomatch = 1:2),
                 "'nomatch' has to be a 'numeric' of length one")
    expect_error(closest(1:3, c(1, NA)), "not contain NA")
    expect_error(closest(1:3, 1:3, duplicates = "foo"), "has to be .*keep.*,")
})

test_that("closest basically works", {
    expect_equal(closest(c(1.4, 9.8, 11.1), 1:10), c(1, 10, 10))
    expect_equal(closest(4:5, 4.8, tolerance = 1), c(1, 1))
    expect_equal(closest(c(0.5, 1.5, exp(1), pi), 1:10), c(1, 1, 3, 3))
})

test_that("closest, invalid table", {
    expect_equal(closest(1:3, integer()), rep(NA_integer_, 3))
})

test_that("closest, disabling .check works", {
    expect_equal(closest(2:1, 1, .check = FALSE), c(1, 1))
})

test_that("closest, length(table) == 1, no tolerance", {
    expect_equal(closest(1:3, 0, nomatch = 0, tolerance = 0), c(0, 0, 0))
    expect_equal(closest(1:3, 1, nomatch = 0, tolerance = 0), c(1, 0, 0))
    expect_equal(closest(1:3, 2, nomatch = 0, tolerance = 0), c(0, 1, 0))
    expect_equal(closest(1:3, 3, nomatch = 0, tolerance = 0), c(0, 0, 1))
    expect_equal(closest(1:3, 4, nomatch = 0, tolerance = 0), c(0, 0, 0))
})

test_that("closest, tolerance/ppm", {
    expect_equal(closest(1.001, 1:10, tolerance = 0), NA_integer_)
    expect_equal(closest(1.001, 1:10, tolerance = 0, ppm = 1), NA_integer_)
    expect_equal(closest(1.4, 1:10, tolerance = 0.4), 1)
    expect_equal(closest(1 + 1 / 1e6, 1:10, tolerance = 0, ppm = 1), 1)
    expect_equal(closest(1e6 + 1:2, 1e6, tolerance = 0, ppm = 1), c(1, NA))

    # exact boundary, see
    # https://github.com/rformassspectrometry/Spectra/pull/45#issuecomment-511680248
    x <- c(1.11, 45.02, 123.45, 556.45)
    y <- c(3.01, 34.12, 45.021, 46.1, x[3] + (x[3] * 5 / 1e6), 556.449)

    expect_equal(closest(x, y, tolerance = 0.01), c(NA, 3L, 5L, 6L))

    # upper boundary
    expect_equal(closest(x, y, tolerance = x * 5 / 1e6), c(NA, NA, 5, 6))
    # lower boundary
    y <- c(3.01, 34.12, 45.021, 46.1, x[3] - (x[3] * 5 / 1e6), 556.449)
    expect_equal(closest(x, y, tolerance = x * 5 / 1e6), c(NA, NA, 5, 6))

    ## Negative values
    expect_equal(closest(-1.001, -(10:1), tolerance = 0), NA_integer_)
    expect_equal(closest(-1.4, -(10:1), tolerance = 0.4), 10)
    expect_equal(closest(-(1 + 1 / 1e6), -(10:1), tolerance = 0, ppm = 1), 10)
    expect_equal(closest(-1e6 - 2:1, -1e6, tolerance = 0, ppm = 1), c(NA, 1))

    a <- c(33, 34, 35)
    expect_equal(closest(34.00034, a, ppm = 10, tolerance = 0), 2L)
    expect_equal(closest(-34.00034, sort(-a), ppm = 10, tolerance = 0), 2L)
})

test_that("closest, duplicates", {
    expect_equal(closest(c(0.8, 1.2), 1, tolerance = 0.3, duplicates = "keep"),
                 c(1, 1))
    expect_equal(closest(c(0.8, 1.2), 1, tolerance = 0.3, duplicates = "closest"),
                 c(1, NA_integer_))
    expect_equal(closest(c(0.8, 1.1), 1, tolerance = 0.3, duplicates = "closest"),
                 c(NA_integer_, 1))
    expect_equal(closest(c(0.8, 1.2), 1, tolerance = 0.3, duplicates = "remove"),
                 c(NA_integer_, NA_integer_))

    expect_equal(closest(1.5, 1:2, tolerance = 0.5, duplicates = "keep"), 1)
    expect_equal(closest(1.5, 1:2, tolerance = 0.5, duplicates = "closest"), 1)
    expect_equal(closest(1.6, 1:2, tolerance = 0.5, duplicates = "keep"), 2)
    expect_equal(closest(1.6, 1:2, tolerance = 0.5, duplicates = "closest"), 2)
    expect_equal(closest(1.5, 1:2, tolerance = 0.5, duplicates = "remove"), 1)

    # equal distances, see
    # https://github.com/rformassspectrometry/MsCoreUtils/issues/65
    x <- as.numeric(c(1, 3, 5, 6, 8))
    y <- as.numeric(c(3, 4, 5, 7))
    expect_equal(closest(x, y, tolerance = 1, duplicates = "closest"),
                 c(NA, 1, 3, 4, NA))
    # multiple match, with better match following, see
    # https://github.com/rformassspectrometry/MsCoreUtils/issues/66
    x <- c(1, 1.5, 2, 2.1, 5, 6, 7)
    y <- c(4.6, 4.7, 4.8, 4.9, 5, 6, 7, 8)
    expect_equal(closest(x, y, tolerance = 3, duplicates = "closest"),
                 c(NA, NA, NA, 1, 5, 6, 7))
})

test_that("common", {
    expect_equal(common(c(1.6, 1.75, 1.8), 1:2, tolerance = 0.5), rep(TRUE, 3))
    expect_equal(common(c(1.6, 1.75, 1.8), 1:2, tolerance = 0.5, duplicates =
                        "closest"), c(FALSE, FALSE, TRUE))
    expect_equal(common(c(1.6, 1.75, 5.8), 1:2, tolerance = 0.5, duplicates =
                        "closest"), c(FALSE, TRUE, FALSE))
    expect_equal(common(c(1.6, 1.75, 1.8), 1:2, tolerance = 0.5, duplicates =
                        "remove"), rep(FALSE, 3))
    # issue 55
    expect_equal(common(1:3, integer()), rep(FALSE, 3))
})

test_that("join", {
    x <- as.numeric(c(1, 2, 3, 6))
    y <- as.numeric(c(3, 4, 5, 6, 7))

    expect_equal(join(x, y, type = "outer"),
                 list(x = c(1:3, NA, NA, 4, NA), y = c(NA, NA, 1:5)))
    expect_equal(join(x, y, type = "left"),
                 list(x = 1:4, y = c(NA, NA, 1, 4)))
    expect_equal(join(x, y, type = "right"),
                 list(x = c(3, NA, NA, 4, NA), y = 1:5))
    expect_equal(join(x, y, type = "inner"),
                 list(x = 3:4, y = c(1, 4)))

    x <- x + c(-0.1, 0.1)
    expect_equal(join(x, y, type = "outer"),
                 list(x = c(1:3, rep(NA, 4), 4, NA),
                      y = c(rep(NA, 3), 1:4, NA, 5)))
    expect_equal(join(x, y, type = "left"),
                 list(x = 1:4, y = rep(NA_integer_, 4)))
    expect_equal(join(x, y, type = "right"),
                 list(x = rep(NA_integer_, 5), y = 1:5))
    expect_equal(join(x, y, type = "inner"),
                 list(x = integer(), y = integer()))
    expect_equal(join(x, y, tolerance = 0.1, type = "outer"),
                 list(x = c(1:3, NA, NA, 4, NA), y = c(NA, NA, 1:5)))
    expect_equal(join(x, y, tolerance = 0.1, type = "left"),
                 list(x = 1:4, y = c(NA, NA, 1, 4)))
    expect_equal(join(x, y, tolerance = 0.1, type = "right"),
                 list(x = c(3, NA, NA, 4, NA), y = 1:5))
    expect_equal(join(x, y, tolerance = 0.1, type = "inner"),
                 list(x = 3:4, y = c(1, 4)))

    x <- x + c(-2, 2) / 1e6
    expect_equal(join(x, y, tolerance = 0.1, type = "outer"),
                 list(x = c(1:3, rep(NA, 4), 4, NA),
                      y = c(rep(NA, 3), 1:4, NA, 5)))
    expect_equal(join(x, y, tolerance = 0.1, type = "left"),
                 list(x = 1:4, y = rep(NA_integer_, 4)))
    expect_equal(join(x, y, tolerance = 0.1, type = "right"),
                 list(x = rep(NA_integer_, 5), y = 1:5))
    expect_equal(join(x, y, tolerance = 0.1, type = "inner"),
                 list(x = integer(), y = integer()))
    expect_equal(join(x, y, tolerance = 0.1, ppm = 2, type = "outer"),
                 list(x = c(1:3, NA, NA, 4, NA), y = c(NA, NA, 1:5)))
    expect_equal(join(x, y, tolerance = 0.1, ppm = 2, type = "left"),
                 list(x = 1:4, y = c(NA, NA, 1, 4)))
    expect_equal(join(x, y, tolerance = 0.1, ppm = 2, type = "right"),
                 list(x = c(3, NA, NA, 4, NA), y = 1:5))
    expect_equal(join(x, y, tolerance = 0.1, ppm = 2, type = "inner"),
                 list(x = 3:4, y = c(1, 4)))

    ## multiple matches
    x <- c(3.95, 4.04)
    expect_equal(join(x, y, tolerance = 0.1, type = "inner"),
                 list(x = 2, y = 2))
    x <- c(1, 8)
    expect_equal(join(x, y, tolerance = 0.1, type = "inner"),
                 list(x = integer(), y = integer()))

    ## no match at all
    x <- as.numeric(c(1, 2, 3, 6))
    y <- as.numeric(c(4, 5, 7))
    expect_equal(join(x, y, type = "outer"),
                 list(x = c(1:3, NA, NA, 4, NA), y = c(NA, NA, NA, 1:2, NA, 3)))
})

test_that("outer join works", {
    x <- as.numeric(c(1, 2, 3, 6))
    y <- as.numeric(c(3, 4, 5, 6, 7))

    expect_error(join(1:3, 4:1, 0, 0, type = "outer"), "sorted")
    expect_error(join(4:1, 1:4, 0, 0, type = "outer"), "sorted")
    expect_error(join(c(1, 2, NA, 3, type = "outer"), 1:4, 0, 0), "sorted")

    expect_equal(join(x, y, 0, 0, type = "outer"),
                 list(x = c(1, 2, 3, NA, NA, 4, NA),
                      y = c(NA, NA, 1, 2, 3, 4, 5)))
    expect_equal(join(x, y, 10, 0, type = "outer"),
                 list(x = c(1, 2, 3, NA, NA, 4, NA),
                      y = c(NA, NA, 1, 2, 3, 4, 5)))
    expect_equal(join(y, x, 10, 0, type = "outer"),
                 list(x = c(NA, NA, 1, 2, 3, 4, 5),
                      y = c(1, 2, 3, NA, NA, 4, NA)))

    x <- c(1, 1.5, 2, 2.1, 5, 6, 7)
    y <- c(4.6, 4.7, 4.8, 4.9, 5, 6, 7, 8)
    expect_equal(join(x, y, 0, 0, type = "outer"),
                 list(x = c(1:4, NA, NA, NA, NA, 5:7, NA),
                      y = c(NA, NA, NA, NA, 1:8)))
    expect_equal(join(y, x, 0, 0, type = "outer"),
                 list(x = c(NA, NA, NA, NA, 1:8),
                      y = c(1:4, NA, NA, NA, NA, 5:7, NA)))
    ## Issue #66: outer join with tolerance 3: expect to have more matches!
    tol_3 <- list(x = c(1, 2, 3, 4, NA, NA, NA, 5, 6, 7, NA),
                  y = c(NA, NA, NA, 1, 2, 3, 4, 5, 6, 7, 8))
    expect_equal(join(x, y, 3, 0, type = "outer"), tol_3)
    tol_3 <- tol_3[2:1]
    names(tol_3) <- c("x", "y")
    expect_equal(join(y, x, 3, 0, type = "outer"), tol_3)

    x <- c(1, 1.5, 2, 2.1, 3, 3.4, 4.1, 4.5, 5, 5.1, 5.2, 6, 14)
    y <- c(4.6, 4.7, 4.8, 4.9, 5, 6, 7, 8)
    tol_3 <- list(
        x = c(1, 2, 3, 4, 5, 6, 7, 8, NA, NA, NA, 9, 10, 11, 12, NA, NA, 13),
        y = c(NA, NA, NA, NA, NA, NA, NA, 1, 2, 3, 4, 5, NA, NA, 6, 7, 8, NA))
    expect_equal(join(x, y, 3, 0, type = "outer"), tol_3)

    x <- c(1, 2, 3, 4)
    y <- c(6, 7, 8)
    join(x, y, 20, 0, type = "outer")
    expect_equal(join(x, y, 0, 0, type = "outer"),
                 list(x = c(1:4, NA, NA, NA), y = c(NA, NA, NA, NA, 1:3)))
    expect_equal(join(x, y, 20, 0, type = "outer"),
                 list(x = c(1:4, NA, NA), y = c(NA, NA, NA, 1:3)))

    ## no match at all
    x <- as.numeric(c(1, 2, 3, 6))
    y <- as.numeric(c(4, 5, 7))
    expect_equal(join(x, y, 0, 0, type = "outer"),
                 list(x = c(1:3, NA, NA, 4, NA), y = c(NA, NA, NA, 1:2, NA, 3)))

    ## identical values
    x <- c(3, 5, 5, 5, 6, 9)
    y <- c(2, 4, 5, 5.5, 7)
    expect_equal(join(x, y, 0, 0, type = "outer"),
                 list(x = c(NA, 1, NA, 2, 3, 4, NA, 5, NA, 6),
                      y = c(1, NA, 2, 3, NA, NA, 4, NA, 5, NA)))
    expect_equal(join(y, x, 0, 0, type = "outer"),
                 list(x = c(1, NA, 2, 3, NA, NA, 4, NA, 5, NA),
                      y = c(NA, 1, NA, 2, 3, 4, NA, 5, NA, 6)))
})

test_that("left join works", {
    x <- as.numeric(c(1, 2, 3, 6))
    y <- as.numeric(c(3, 4, 5, 6, 7))

    expect_error(join(1:3, 4:1, 0, 0, type = "left"), "sorted")
    expect_error(join(4:1, 1:4, 0, 0, type = "left"), "sorted")
    expect_error(join(c(1, 2, NA, 3, type = "left"), 1:4, 0, 0), "sorted")

    expect_equal(join(x, y, tolerance = 0, ppm = 0, type = "left"),
                 list(x = 1:4, y = c(NA, NA, 1, 4)))
    expect_equal(join(x, y, tolerance = 5, ppm = 0, type = "left"),
                 list(x = 1:4, y = c(NA, NA, 1, 4)))

    x <- as.numeric(c(1, 3, 5, 6, 8))
    y <- as.numeric(c(3, 4, 5, 7))
    expect_equal(join(x, y, 0, 0, type = "left"),
                 list(x = 1:5, y = c(NA, 1, 3, NA, NA)))
    expect_equal(join(y, x, 0, 0, type = "left"),
                 list(x = 1:4, y = c(2, NA, 3, NA)))
    expect_equal(join(x, y, 1, 0, type = "left"),
                 list(x = 1:5, y = c(NA, 1, 3, 4, NA)))
    expect_equal(join(y, x, 1, 0, type = "left"),
                 list(x = 1:4, y = c(2, NA, 3, 4)))

    x <- c(133.0759, 133.0775, 133.9788, 133.9804, 133.9820, 133.9837)
    y <- c(133.9755, 133.9771, 133.9788, 133.9804, 133.9820, 133.9836)
    expect_equal(join(x, y, 0, 0, type = "left"),
                 list(x = 1:6, y = c(NA, NA, 3, 4, 5, NA)))
    expect_equal(join(x, y, 0.01, 0, type = "left"),
                 list(x = 1:6, y = c(NA, NA, 3, 4, 5, 6)))
    expect_equal(join(x, y, 1, 0, type = "left"),
                 list(x = 1:6, y = c(NA, 1, 3, 4, 5, 6)))

    x <- c(1, 1.5, 2, 2.1, 5, 6, 7)
    y <- c(4.6, 4.7, 4.8, 4.9, 5, 6, 7, 8)
    expect_equal(join(x, y, 0, 0, type = "left"),
                 list(x = 1:7, y = c(NA, NA, NA, NA, 5, 6, 7)))
    expect_equal(join(x, y, 1, 0, type = "left"),
                 list(x = 1:7, y = c(NA, NA, NA, NA, 5, 6, 7)))
    expect_equal(join(x, y, 3, 0, type = "left"),
                 list(x = 1:7, y = c(NA, NA, NA, 1, 5, 6, 7)))
    expect_equal(join(x, y, 10, 0, type = "left"),
                 list(x = 1:7, y = c(NA, NA, NA, 1, 5, 6, 7)))
    expect_equal(join(y, x, 0, 0, type = "left"),
                 list(x = 1:8, y = c(NA, NA, NA, NA, 5, 6, 7, NA)))
    expect_equal(join(y, x, 10, 0, type = "left"),
                 list(x = 1:8, y = c(NA, NA, NA, NA, 5, 6, 7, NA)))
})
