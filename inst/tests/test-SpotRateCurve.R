
context('spotratecurve class')

terms <- c(1, 11, 26, 27, 28)
rates <- c(0.0719, 0.056, 0.0674, 0.0687, 0.07)


test_that("it should create an interest rate curve", {
  curve <- spotratecurve(rates, terms, "discrete", "actual/365", "actual")
  expect_is(curve, "spotratecurve")
  expect_is(curve, "spotrate")
  expect_equal(as.numeric(curve), rates)
  expect_equal(curve@terms, terms)
  expect_is(curve@compounding, "discrete")
  expect_is(curve@daycount, "daycount")
  expect_equal(curve@calendar, "actual")
})

test_that("it should check if terms and rates have the same length", {
  expect_error(
    spotratecurve(rates, terms[-1], "discrete", "actual/365", "actual")
  )
})

test_that("it should check if terms are unique", {
  expect_error(
    spotratecurve(rates, rep(1, length(rates)), "discrete", "actual/365", "actual")
  )
})

test_that("it should check if terms positive", {
  expect_error(
    spotratecurve(rates, -terms, "discrete", "actual/365", "actual")
  )
})

test_that("it should create a spotratecurve using a spotrate", {
  spr <- spotrate(rates, "simple", 'actual/365', 'actual')
  curve <- spotratecurve(spr, terms)
  expect_equal(as.numeric(curve), rates)
  expect_equal(curve@terms, terms)
  expect_is(curve@compounding, "simple")
  expect_is(curve@daycount, "daycount")
  expect_equal(curve@calendar, "actual")
})

test_that("it should handle terms if they are not ordered", {
  spr <- spotrate(rates, "simple", "actual/365", "actual")
  .terms <- sample(terms)
  ix <- order(.terms)
  curve <- spotratecurve(spr, .terms)
  expect_equal(as.numeric(curve), rates[ix])
  expect_equal(curve@terms, terms)
})


test_that("it should return the curve's length", {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  expect_equal(length(curve), 5)
})

test_that("it should check if indexed the elements is spotrate", {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  expect_is(curve[1], 'spotratecurve')
})

test_that("it should index the elements", {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  expect_equal(as.numeric(curve[11]), 0.056)
  expect_equal(curve[11]@terms, 11)
  expect_equal(curve[c(1, 11)]@terms, c(1, 11))
  expect_equal(as.numeric(curve[c(1, 11)]), c(0.0719, 0.056))
})

test_that("it should return a NA spotrate for unexistent indexes", {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  expect_is(curve[10], "spotratecurve")
  expect_true(is.na(curve[10]))
  expect_equal(curve[10]@terms, 10)
  expect_equal(length(curve[10]), 1)
  expect_equal(as.numeric(curve[c(10, 11)]), c(NA, 0.056))
  expect_equal(length(curve[c(10, 11)]), 2)
})

test_that("it should replace or insert elements into the curve", {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  # insert one new element
  curve[10] <- 0.051
  expect_is(curve[10], "spotratecurve")
  expect_equal(as.numeric(curve[10]), 0.051)
  expect_equal(length(curve), length(terms)+1)
  expect_equal(match(10, curve@terms), 2)
  # insert more new elements
  curve[c(8, 9)] <- c(0.048, 0.049)
  expect_equal(as.numeric(curve[c(8, 9)]), c(0.048, 0.049))
  expect_equal(match(c(8, 9), curve@terms), c(2, 3))
  # 2
  curve[c(12, 13)] <- 0.049
  expect_equal(as.numeric(curve[c(12, 13)]), c(0.049, 0.049))
  # replace one element
  len_ <- length(curve)
  curve[11] <- 0.051
  expect_equal(as.numeric(curve[11]), 0.051)
  expect_equal(length(curve), len_)
  # replace more elements
  len_ <- length(curve)
  curve[c(1, 11)] <- c(0.051, 0.051)
  expect_equal(as.numeric(curve[c(1, 11)]), c(0.051, 0.051))
  expect_equal(length(curve), len_)
  # 2
  curve[c(1, 11)] <- 0.05
  expect_equal(as.numeric(curve[c(1, 11)]), c(0.05, 0.05))
  expect_equal(length(curve), len_)
  # insert and replace
  len_ <- length(curve)
  curve[c(29, 26, 25)] <- 0.07
  expect_equal(as.numeric(curve[c(25, 26, 29)]), c(0.07, 0.07, 0.07))
  expect_equal(length(curve), len_+2)
  # 2
  curve[c(31, 28, 35)] <- c(0.071, 0.072, 0.073)
  expect_equal(as.numeric(curve[c(31, 28, 35)]), c(0.072, 0.071, 0.073))
  # replace one element with another spotrate
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  curve[13] <- curve[1]
  expect_equal(as.numeric(curve[13]), as.numeric(curve[1]))
  curve[c(31, 28, 35)] <- curve[c(1, 11, 26)]
  expect_equal(as.numeric(curve[c(31, 28, 35)]), as.numeric(curve[c(1, 11, 26)])[c(2, 1, 3)])
  curve[11] <- curve[100]
  expect_true(is.na(curve[11]))
})

test_that('it should return the curve\'s head', {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  hr <- head(curve, 3)
  expect_is(hr, 'spotratecurve')
  expect_equal(length(hr), 3)
  expect_equal(as.numeric(hr), head(rates, 3))
  expect_equal(hr@terms, head(terms, 3))
})

test_that('it should return the curve\'s tail', {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  hr <- tail(curve, 3)
  expect_is(hr, 'spotratecurve')
  expect_equal(length(hr), 3)
  expect_equal(as.numeric(hr), tail(rates, 3))
  expect_equal(hr@terms, tail(terms, 3))
})

test_that("it should subset the curve with boolean index", {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  curve1 <- curve[terms > 20]
  expect_is(curve1, 'spotratecurve')
  expect_true(all(curve1@terms > 20))
  # recicle rule
  ix <- c(TRUE, FALSE)
  curve1 <- curve[ix]
  expect_is(curve1, 'spotratecurve')
  expect_equal(curve1@terms, terms[ix])
  expect_equal(as.numeric(curve1), rates[ix])
})

test_that("it should coerce a spotratecurve into a data.frame", {
  curve <- spotratecurve(rates, terms, "simple", "actual/365", "actual")
  expect_equal(as.data.frame(curve), data.frame(terms = terms, rates = rates))
})

# test_that("it should interpolate", {
#   spr <- as.spotrate(rates, simpleCompounding(), as.daycount('actual/365'))
#   curve <- as.spotratecurve(terms, spr, interp=linear)
#   expect_true(curve[21] == 0.0636)
#   expect_true(all(curve[c(11, 21, 26)] == c(0.0560, 0.0636, 0.0674)))
# })
# 
# test_that("it should create a curve using dates", {
#   library(bizdays)
#   spr <- as.spotrate(rates, simpleCompounding(), as.daycount('actual/365'), Calendar(name='Actual'))
#   curve <- as.spotratecurve(terms+Sys.Date(), spr, refdate=Sys.Date(), interp=linear)
#   expect_is(curve, "spotratecurve")
#   expect_is(terms(curve), "Date")
#   expect_true(all(terms(curve) == terms+Sys.Date()))
#   expect_true(all(terms(curve, as.x=TRUE) == terms))
# })
# 
# test_that("it should interpolate a curve using dates", {
#   library(bizdays)
#   spr <- as.spotrate(rates, simpleCompounding(), as.daycount('actual/365'), Calendar(name='Actual'))
#   curve <- as.spotratecurve(terms+as.Date('2014-07-01'), spr, refdate=as.Date('2014-07-01'))
#   expect_true(curve['2014-07-02'] == 0.0719)
#   expect_equal(rates(curve[c('2014-07-02', '2014-07-03')]), c(0.0719, 0.07031))
#   expect_true(curve['2014-07-04'] == curve[3])
# })
# 
# test_that("it should replace a curve element using dates", {
#   library(bizdays)
#   spr <- as.spotrate(rates, simpleCompounding(), as.daycount('actual/365'), Calendar(name='Actual'))
#   curve <- as.spotratecurve(terms+as.Date('2014-07-01'), spr, refdate=as.Date('2014-07-01'))
#   curve['2014-07-02'] <- 1
#   expect_true(curve['2014-07-02'] == 1)
#   curve['2014-07-03'] <- 1
#   expect_true(curve[2] == 1)
#   curve[c('2014-07-04', '2014-07-05')] <- 1
#   expect_true(all(curve[c(3, 4)] == 1))
# })
# 
# test_that("it should create a curve using numeric and dates", {
#   library(bizdays)
#   cal <- Calendar(name='Actual')
#   spr <- as.spotrate(rates, simpleCompounding(), as.daycount('actual/365'), cal)
#   curve <- as.spotratecurve(terms, spr, refdate=Sys.Date(), interp=linear)
#   expect_is(curve, "spotratecurve")
#   expect_is(terms(curve), "Date")
#   .terms <- sapply(terms, function(x) add.bizdays(Sys.Date(), x, cal))
#   expect_true(all(terms(curve) == .terms))
#   expect_true(all(terms(curve, as.x=TRUE) == terms))
# })
# 
# test_that("it should interpolate a curve using dates and numbers", {
#   library(bizdays)
#   cal <- Calendar(name='Actual')
#   spr <- as.spotrate(rates, 'simple', 'actual/365', cal)
#   curve <- as.spotratecurve(terms, spr, refdate='2014-07-01', interp=linear)
#   expect_true(curve['2014-07-02'] == curve[1])
#   expect_equal(rates(curve[c('2014-07-02', '2014-07-03')]), rates(curve[c(1, 2)]))
#   expect_true(curve['2014-07-04'] == curve[3])
# })
# 
# test_that("it should compute forward rates", {
#   spr <- as.spotrate(rates, 'simple', 'actual/365')
#   curve <- as.spotratecurve(terms, spr)
#   rate <- as.spotrate(0.05439928, 'simple', 'actual/365')
#   expect_error(forwardrate(curve, 1, 1), "to term must be greater than from." )
#   expect_equal(forwardrate(curve, 1, 11), rate, tolerance=1e-6)
#   expect_equal(forwardrate(curve, 1, forward=1), curve[1])
#   expect_equal(forwardrate(curve, 1, forward=10), rate, tolerance=1e-6)
#   
#   f1 <- curve[10]
#   f2 <- forwardrate(curve, 10, forward=1)
#   expect_equal(compound(f1, 10) * compound(f2, 1), compound(curve[11], 11) )
#   f1 <- curve[1]
#   f2 <- forwardrate(curve, 1, forward=1)
#   expect_equal(compound(f1, 1) * compound(f2, 1), compound(curve[2], 2),
#     tolerance=1e-5)
#   expect_error(forwardrate(curve, 1),
#     "to or forward arguments must be provided." )
# })
# 
# test_that("it should compute forward rates (vectorized)", {
#   spr <- as.spotrate(rates, 'simple', 'actual/365')
#   curve <- as.spotratecurve(terms, spr)
#   rate <- as.spotrate(c(0.05439928, 0.05439928), 'simple', 'actual/365')
#   expect_equal(forwardrate(curve, 1, c(11, 11)), rate, tolerance=1e-6)
#   expect_equal(forwardrate(curve, c(1, 1), c(11, 11)), rate, tolerance=1e-6)
#   expect_equal(forwardrate(curve, c(1, 1), 11), rate, tolerance=1e-6)
#   # expect_equal(forwardrate(curve, 1, forward=c(1, 1)), curve[c(1, 1)])
#   # expect_equal(forwardrate(curve, 1, forward=10), rate, tolerance=1e-6)
# })
# 
# test_that("it should compute forward rates using dates", {
#   library(bizdays)
#   cal <- Calendar(name='Actual')
#   spr <- as.spotrate(rates, 'simple', 'actual/365', cal)
#   refdate <- as.Date('2014-07-01')
#   curve <- as.spotratecurve(terms+refdate, spr, refdate=refdate)
#   rate <- as.spotrate(0.05439928, 'simple', 'actual/365', cal)
# 
#   expect_error(forwardrate(curve, refdate+1, refdate+1),
#     "to term must be greater than from.")
#   expect_equal(forwardrate(curve, refdate+1, refdate+11), rate, tolerance=1e-6)
#   expect_equal(forwardrate(curve, refdate+1, forward=1), curve[1])
#   expect_equal(forwardrate(curve, refdate+1, forward=10), rate, tolerance=1e-6)
#   
#   f1 <- curve[refdate+10]
#   f2 <- forwardrate(curve, refdate+10, forward=1)
#   expect_equal(compound(f1, 10) * compound(f2, 1),
#     compound(curve[refdate+11], 11) )
#   f1 <- curve[refdate+1]
#   f2 <- forwardrate(curve, refdate+1, forward=1)
#   expect_equal( compound(f1, 1) * compound(f2, 1),
#     compound(curve[refdate+2], 2), tolerance=1e-5)
# })
# 
# test_that("it should compound curve", {
#   spr <- as.spotrate(rates, 'simple', 'actual/365')
#   curve <- as.spotratecurve(terms, spr)
#   expect_equal(compound(curve, 11), 1.00168767)
#   expect_equal(compound(curve, c(11, 26)), c(1.00168767, 1.004801096))
# 
#   library(bizdays)
#   cal <- Calendar(name='Actual')
#   spr <- as.spotrate(rates, 'simple', 'actual/365', cal)
#   curve <- as.spotratecurve(terms, spr, refdate='2014-07-01', interp=linear)
#   expect_equal(compound(curve, '2014-07-12'), 1.00168767)
#   expect_equal(compound(curve, c('2014-07-12', '2014-07-27')),
#     c(1.00168767, 1.004801096))
# })
# 
# test_that('it should call [[ which returns a numeric value', {
#   spr <- as.spotrate(rates, 'simple', 'actual/365')
#   curve <- as.spotratecurve(terms, spr)
#   i <- curve[[21]]
#   expect_true(is.numeric(i))
#   expect_true(i == 0.0636)
#   expect_error(curve[[1:10]])
#   expect_error(curve[[-1]])
# })

# test_that('it should append a SpotRate to a SpotRateCurve', {
#     curve[32] <- 0.0643
#     expect_equal(length(curve), 6)
#     expect_equal(terms(curve), c(1, 11, 26, 27, 28, 32))
#     expect_equal(rates(curve), c(0.0719, 0.056, 0.0674, 0.0687, 0.07, 0.0643))
#
#     curve[3] <- 0.07
#     expect_equal(length(curve), 7)
#     expect_equal(terms(curve), c(1, 3, 11, 26, 27, 28, 32))
#     expect_equal(rates(curve), c(0.0719, 0.07, 0.056, 0.0674, 0.0687, 0.07, 0.0643))
#
#     curve[3] <- 0.06
#     expect_equal(length(curve), 7)
#     expect_equal(terms(curve), c(1, 3, 11, 26, 27, 28, 32))
#     expect_equal(rates(curve), c(0.0719, 0.06, 0.056, 0.0674, 0.0687, 0.07, 0.0643))
#
#     curve[c(3,7,6)] <- c(0.059, 0.058, 0.057)
#     expect_equal(length(curve), 9)
#     expect_equal(terms(curve), c(1, 3, 6, 7, 11, 26, 27, 28, 32))
#     expect_equal(rates(curve), c(0.0719, 0.059, 0.057, 0.058, 0.056, 0.0674, 0.0687, 0.07, 0.0643))
# })
#
# test_that('it should find the neighbors for a given term', {
#     expect_equal(neighbors(curve, 11), c(11, 11))
#     expect_equal(neighbors(curve, 21), c(11, 26))
# })
#
# test_that('it should define a datum and a Calendar to a curve', {
# 	terms <- c(1, 11, 26, 27, 28)
# 	rates <- c(0.0719, 0.056, 0.0674, 0.0687, 0.07)
# 	curve <- SpotRateCurve(rates, terms, datum='2013-10-28')
# 	expect_equal(datum(curve), as.Date('2013-10-28'))
# })
#
# test_that('it should define a name to a curve', {
# 	terms <- c(1, 11, 26, 27, 28)
# 	rates <- c(0.0719, 0.056, 0.0674, 0.0687, 0.07)
# 	curve <- SpotRateCurve(rates, terms, name='CURVE')
# 	expect_equal(name(curve), 'CURVE')
# })

# test_that('it should return the curve\'s tail', {
# 	terms <- c(1, 11, 26, 27, 28, 30)
# 	rates <- c(0.0719, 0.056, 0.0674, 0.0687, 0.07, 0.07)
# 	curve <- SpotRateCurve(rates, terms)
# 	expect_is(tail(curve), 'SpotRateCurve')
# 	expect_equal(length(tail(curve, 3)), 3)
# 	expect_equal(tail(curve), curve)
# 	expect_error(tail(curve, 10))
# })
