{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Home where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import Yesod
import Text.Julius (RawJS (..))
import qualified Data.Text as T
import qualified Data.ByteString.Lazy as B
import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH
import System.Random
import Network.HTTP.Simple

-- Define our data that will be used for creating the form.

-- This is a handler function for the GET request method on the HomeR
-- resource pattern. All of your resource patterns are defined in
-- config/routes.yesodroutes
--
-- The majority of the code you will write in Yesod lives in these handler
-- functions. You can spread them across multiple files if you are so
-- inclined, or create a single monolithic file.

random3 :: IO Integer
random3 =  mod <$> randomIO <*> (pure 3)

randomAdj :: IO String 
randomAdj = do
   n <- random3
   return (case n of
               0 -> "a beautiful"
               1 -> "a radiant"
               2 -> "an ostentatious")
   
widgetAdj :: Widget
widgetAdj = do
   adj <- liftIO randomAdj
   toWidget [hamlet| #{adj} |]

horseForm :: Html -> MForm Handler (FormResult Horse, Widget)
horseForm = renderDivs $ Horse
   <$> areq textField "Name" Nothing
   <*> areq textField "Color" Nothing

getHomeR :: Handler Html
getHomeR = do
   (widget, enctype) <- generateFormPost horseForm 
   horses <- runDB $ selectList ([] :: [Filter Horse]) []
      -- Entity horseId Horse
   defaultLayout $ do
      setTitle "SUPER HORSE SIMULATOR 2"
      toWidget [lucius|
         h1, h2 {color: green; text-align: center}
         * {
            max-width: 500px;
            margin: auto
         }
         |]
      [whamlet|
         <h1>SUPER HORSE SIMULATOR 2:
                 <h2>MAXIMUM LENGTH

         <p> Here are your horses:
         $if null horses
            <p> you currently have no horses. Bro you gotta make horses!
         $else
            <ul>
               $forall Entity horseId (Horse name color) <- horses
                  <li>#{name}, with ^{widgetAdj} #{color} coat.
                   ^{horsePic horseId}
         <form method=post action=@{HorseR} enctype=#{enctype}>
            ^{widget}
            <button>Submit
      |]

horsePic :: Key Horse -> Widget
horsePic horseId = do
   filename <- pure $ (show $ fromSqlKey horseId)
   toWidget [hamlet|
      <img src=static/#{filename}>
   |]

saveHorse :: String -> IO ()
saveHorse id = do
   response <- httpLBS $ parseRequest_ "https://thishorsedoesnotexist.com/"
   let status = getResponseStatusCode response
   if status == 200
      then do
         let pic = getResponseBody response
         B.writeFile ("./static/" ++ id) pic
      else print "failed to save the horse pic :("

postHorseR :: Handler Html
postHorseR = do
   ((result, widget), enctype) <- runFormPost horseForm
   case result of
         FormSuccess horse -> do
              horseId <- runDB $ insert horse
              liftIO $ saveHorse $ show (fromSqlKey horseId)
              defaultLayout [whamlet|<p>#{show horse}|]
              redirect HomeR
         _ -> defaultLayout
               [whamlet|
                  <p>Invalid input, let's try again.
                  <form method=post action=@{HomeR} enctype=#{enctype}>
                     ^{widget}
                     <button>Submit
               |]

