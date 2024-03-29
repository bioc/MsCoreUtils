#' @title Forcing a numeric vector into a monotonously increasing sequence.
#'
#' @description
#' This function performs interpolation on the non-increasing parts of a
#' numeric input vector to ensure its values are monotonously increasing.
#' If the values are non-increasing at the end of the vector, these values will
#' be replaced by a sequence of numeric values, starting from the last
#' increasing value in the input vector, and increasing by a very small value,
#' which can be defined with parameter `by `
#'
#' @param x `numeric` vector.
#'
#' @param by `numeric(1)` value that will determine the monotonous increase in
#'        case the values at the end of the vector are non-increasing and
#'        therefore interpolation would not be possible. Defaults
#'        to `by = .Machine$double.eps` which is the smallest positive
#'        floating-point number x such that 1 + x != 1.
#'
#' @return A vector with continuously increasing values.
#'
#' @note
#' NA values will not be replaced and be returned as-is.
#'
#' @examples
#' x <- c(NA, NA, NA, 1.2, 1.1, 1.14, 1.2, 1.3, NA, 1.04, 1.4, 1.6, NA, NA)
#' y <- force_sorted(x)
#' is.unsorted(y, na.rm = TRUE)
#'
#' ## Vector non increasing at the end
#' x <- c(1, 2, 1.5, 2)
#' y <- force_sorted(x, by = 0.1)
#' is.unsorted(y, na.rm = TRUE)
#'
#' ## We can see the values were not interpolated but rather replaced by the
#' ## last increasing value `2` and increasing by 0.1.
#' y
#'
#' @export
#'
#' @rdname force_sorted
force_sorted <- function(x, by = .Machine$double.eps) {
    # Select only the non-NA values
    if (!is.numeric(x) && !is.integer(x))
        stop("'x' needs to be numeric or integer")
    nna_idx <- which(!is.na(x))
    vec_temp <- x[nna_idx]

    while (any(diff(vec_temp) < 0)) {
        idx <- which.max(diff(vec_temp) < 0)
        # Find next biggest value
        next_idx <- which(vec_temp > vec_temp[idx])[1L]

        if (is.na(next_idx)) {
            l <- idx:length(vec_temp)
            vec_temp[l] <- seq(vec_temp[idx], by = by,
                               length.out = length(l))
            warning("Found decreasing values at the end of the vector. ",
                    "Interpolation is not possible in this region. Instead, ",
                    "replacing these values with a sequence that starts from ",
                    "the last increasing value and increments by ", by,
                    ". See help for more details")
            break
        }
        # Interpolation
        idx_range <- idx:next_idx
        vec_temp[idx_range] <- seq(vec_temp[idx], vec_temp[next_idx],
                                   length.out = length(idx_range))
    }
    x[nna_idx] <- vec_temp
    x
}

